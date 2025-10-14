settings:
{ lib, pkgs, ... }:

let
  # Assumption is that this is the version of the release channel that is pinned
  # in the starter kit flake
  stateVersion = settings.stateVersion or "25.05";
  inherit (settings) username;
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  home = {
    inherit username stateVersion homeDirectory;
    sessionVariables = rec {
      # NOTE: point this to your local howto checkout
      TEXINPUTS = "${homeDirectory}/howto/tex:";
      EDITOR = "emacsclient";
      VISUAL = EDITOR;
      ALTERNATE_EDITOR = "";
    };
    packages = [ ];
  };

  # NOTE: Change things to your liking here!
  active-group = {
    nix-starter-kit.enable = true;
    mac-app-util.enable = pkgs.stdenv.isDarwin;
    controlling.enable = false;
    emacs = {
      enable = true;
      additionalPackages = _: [ ];
    };
    git = {
      enable = true;
      userName = settings.userFullName;
      userEmail = settings.email;
    };
    zsh.enable = true;
    timetracking.enable = true;
  };
}
