{ ... }:

let
  settings = import ./user-settings.nix;
  # Assumption is that this is the version of the release channel from which
  # nixpkgsRev comes. NOTE: When changing the release version, the bootstrapping
  # script and CI definition need to be adapted accordingly!
  stateVersion = settings.stateVersion or "24.11";
  # NOTE: When updating the setup within the same release channel, put its
  # latest commit here.
  nixpkgsRev = "fecfeb86328381268e29e998ddd3ebc70bbd7f7c";
  nixpkgs =
    settings.nixpkgs or (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsRev}.tar.gz";
      sha256 = "0m52nb9p4q468pgi1657dzcpsrxd1f15flxljaplxzjyiwbrzz5f";
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
      enableFishIntegration = true;
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
