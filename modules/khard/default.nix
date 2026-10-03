{
  config,
  lib,
  ...
}:

let
  cfg = config.active-group.khard;

  addressbookModule =
    { name, ... }:
    {
      options = {
        path = lib.mkOption {
          type = lib.types.str;
          description = "Absolute path to the directory containing the .vcf files of address book `${name}`.";
          example = "/home/<mitarbeity>/ag/addresses/vcf";
        };
      };
    };
in
{
  options.active-group.khard = {
    enable = lib.mkEnableOption "khard";

    addressbooks = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule addressbookModule);
      default = { };
      description = "Address books to make available in khard, keyed by name.";
      example = lib.literalExpression ''
        {
          ag.path = "/home/<mitarbeity>/ag/addresses/vcf";
          reboot-2026.path = "/home/<mitarbeity>/ag/pr-addresses/reboot-2026";
        }
      '';
    };

    # kept for backwards compatibility
    storagePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Deprecated: use `active-group.khard.addressbooks.ag.path` instead.";
    };
  };

  config = lib.mkIf cfg.enable {
    warnings = lib.optional (cfg.storagePath != null)
      "active-group.khard.storagePath is deprecated; use active-group.khard.addressbooks.ag.path instead.";

    active-group.khard.addressbooks.ag = lib.mkIf (cfg.storagePath != null) {
      path = cfg.storagePath;
    };

    assertions = [
      {
        assertion = cfg.addressbooks != { };
        message = "active-group.khard is enabled but no address books are configured.";
      }
    ];

    programs.khard  = {
      enable = true;
      settings = {
        vcard = {
          # Stored in the vCard as X-Homepage, X-Category, ...
          # Labels may only contain letters, digits and "-"
          private_objects = [ "Homepage" "Category" "AG-Christmas" "Salutation" ];
        };
      };
    };

    accounts.contact.accounts = lib.mapAttrs (_name: ab: {
      local.path = ab.path;
      khard.enable = true;
    }) cfg.addressbooks;
  };
}
