{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.active-group.nix-starter-kit.enable = lib.mkEnableOption "nix-starter-kit";

  config = lib.mkIf config.active-group.nix-starter-kit.enable {
    home = {
      packages = with pkgs; [
        bat
        coreutils
        curl
        fd
        gnupg
        gnutls
        khard
        nixVersions.latest
        openssh
        pandoc
        ripgrep
        rsync
        sieve-connect
        sshpass
        subversion
        texinfo
        texlive.combined.scheme-full
        unzip
        wget
        xz
        zip
      ];
    };

    programs = {
      home-manager.enable = true;
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      fish = {
        enable = true;
        interactiveShellInit = ''
          if test -e /nix/var/nix/profiles/default/etc/profile.d/etc/nix-daemon.fish
              source /nix/var/nix/profiles/default/etc/profile.d/etc/nix-daemon.fish
          end
        '';
        shellAbbrs = {
          home = "cd ~/.config/home-manager";
        };
      };
    };
  };
}
