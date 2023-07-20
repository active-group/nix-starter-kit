username: {
  config,
  pkgs,
  ...
}: {
  imports = [./emacs];

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
    git = {
      # FIXME: Change to your own credentials
      userName = "still empty";
      userEmail = "still.empty@active-group.de";
      ignores = [ ".DS_Store" "*~" "\\#*\\#" ".\\#*" ];
      extraConfig = {
        core.askPass = "";
        init.defaultBranch = "main";
        submodule.recurse = true;
      };
    };
    home-manager.enable = true;
    kitty = {
      enable = true;
      shellIntegration.mode = "disabled";
      settings = {
        shell = "${pkgs.lib.getExe pkgs.fish}";
        enable_audio_bell = "no";
      };
    };
    nix-index = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      # Fallback for when macOS upgrades inevitably destroy the
      # relevant section of /etc/zshrc
      initExtra = ''
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      '';
    };
  };
}
