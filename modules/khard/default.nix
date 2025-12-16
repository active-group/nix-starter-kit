{
  config,
  lib,
  ...
}:

let
  cfg = config.active-group.khard;
in
{
  options.active-group.khard = {
    enable = lib.mkEnableOption "khard";
    storagePath = lib.mkOption {
      type = lib.types.str;
      description = "A string representing the absolute path to vcf files.";
      example = "/home/<mitarbeity>/ag/addresses/vcf";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.khard = {
      enable = true;
    };
    accounts.contact = {
      accounts.ag = {
        local = {
          path = cfg.storagePath;
        };
        khard = {
          enable = true;
        };
      };
    };
  };
}
