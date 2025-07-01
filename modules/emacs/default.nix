{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.active-group.emacs;
  inherit (lib) types;
in
{
  options.active-group.emacs = {
    enable = lib.mkEnableOption "emacs";
    additionalPackages = lib.mkOption {
      type = types.functionTo (types.listOf types.package);
      default = _: [ ];
      example = p: [ p.magit ];
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      file.".config/ag-emacs" = {
        source = ./ag-emacs;
        recursive = true;
      };

      packages =
        let
          myEmacs = pkgs.emacs.pkgs.withPackages (
            p:
            [
              p.use-package
              p.vertico
              p.which-key
              p.auctex
              p.orderless
              p.consult
              p.rg
              p.marginalia
              p.exec-path-from-shell
              p.ledger-mode
              p.magit
            ]
            ++ (cfg.additionalPackages p)
          );
        in
        [ myEmacs ];
    };
  };
}
