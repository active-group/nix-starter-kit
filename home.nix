{ ... }:

let
  settings = import ./user-settings.nix;
  stateVersion = settings.stateVersion or "24.11";
  nixpkgs =
    settings.nixpkgs or (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/release-${stateVersion}.tar.gz";
      sha256 = "1ad5im2zsbpnsha6sfxskifchxn2pr4lvkjr2f5xmbcw2v29k49f";
    });
  pkgs = import nixpkgs { };
in
{
  imports = settings.additionalModules settings;

  home = rec {
    inherit (settings) username;
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";

    sessionVariables = rec {
      EDITOR = "emacsclient";
      VISUAL = EDITOR;
      ALTERNATE_EDITOR = "";
      # NOTE: We assume that the howto directory sits at ~/howto!
      TEXINPUTS = "${homeDirectory}/howto/tex:";
    };

    packages =
      (settings.additionalPackages pkgs)
      ++ (with pkgs; [
        bat
        curl
        fd
        git
        gnupg
        gnutls
        home-manager
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
      ]);

    file.".config/zsh/ag.zsh".source = ./zsh/ag.zsh;

    inherit stateVersion;
  };

  programs = {
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
}
