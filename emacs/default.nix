settings:
{
  config,
  pkgs,
  lib,
  ...
}:
{
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
          ++ (settings.additionalEmacsPackages p)
        );
      in
      [ myEmacs ];
  };
}
