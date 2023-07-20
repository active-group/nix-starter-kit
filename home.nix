username: {
  config,
  pkgs,
  ...
}: {
  home = {
    inherit username;
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "/Users/${username}"
      else "/home/${username}";

    sessionVariables = rec {
      EDITOR = "emacs";
      VISUAL = EDITOR;
      ALTERNATE_EDITOR = "";
    };

    imports = [./emacs];

    packages = with pkgs; [
      bat
      curl
      fd
      git
      gnupg
      gnutls
      texlive.combined.scheme-full
      openssh
      pandoc
      ripgrep
      rsync
      sieve-connect
      sshpass
      subversion
      texinfo
      unzip
      wget
      xz
      zip
    ];

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.05"; # Please read the comment before changing.
  };

  programs = {
    fish.enable = true;
    home-manager.enable = true;
    nix-index = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}
