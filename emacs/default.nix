{
  config,
  pkgs,
  inputs,
  ...
}: {
  home = {
    activation = {
      symlinkDotEmacs = inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -e $HOME/.emacs.d ]; then
            $DRY_RUN_CMD ln -snf $HOME/.config/home-manager/emacs/.emacs.d $HOME/.emacs.d
          fi
        '';
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
