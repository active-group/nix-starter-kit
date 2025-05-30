{ lib, ... }:

let
  settings = import ./user-settings.nix;
  # Assumption is that this is the version of the release channel from which
  # nixpkgsRev comes. NOTE: When changing the release version, the bootstrapping
  # script and CI definition need to be adapted accordingly!
  stateVersion = settings.stateVersion or "24.11";
  # NOTE: When updating the setup within the same release channel, put its
  # latest commit here.
  # NixOS 25.05 as of 2025-05-27
  nixpkgsRev = "101f54e74e5b9969bba239480e2e77c4aac0c3e0";
  nixpkgs =
    settings.nixpkgs or (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsRev}.tar.gz";
      sha256 = "10y128y7y93p88w7s2d65333yk551jxdg8qdv757yby223jmq20p";
    });
  pkgs = import nixpkgs { };
in
{
  imports =
    settings.additionalModules settings
    ++ pkgs.lib.optional pkgs.stdenv.hostPlatform.isDarwin (import ./mac-app-util);

  home = rec {
    inherit (settings) username;
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";

    # this belongs with mac-app-util (but difficult to do there)
    # delete the Mac trampolines so they get re-created, which
    # sometimes fixes problems
    activation = {
      ${if pkgs.stdenv.isDarwin then "deleteMacAppTrampolines" else null} = lib.hm.dag.entryBefore [
        "trampolineApps"
      ] ''$DRY_RUN_CMD rm -rf "$HOME/Applications/Home Manager Trampolines"'';
    };

    enableNixpkgsReleaseCheck = false;

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
}
