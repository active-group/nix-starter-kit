{
  config,
  pkgs,
  ...
}: {
  home = {
    file.".emacs.d" = {
      source = ./.emacs.d;
      recursive = true;
    };

    packages = let
      myEmacs = pkgs.emacsWithPackages (p: [
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
      ]);
    in [myEmacs];
  };
}
