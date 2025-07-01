settings:
{ lib, pkgs, ... }:

let
  # Assumption is that this is the version of the release channel from which
  # nixpkgsRev comes.
  stateVersion = settings.stateVersion or "24.11";
  inherit (settings) username;
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  home = {
    inherit username stateVersion homeDirectory;
    sessionVariables = rec {
      # NOTE: We assume that the howto directory sits at ~/howto!
      TEXINPUTS = "${homeDirectory}/howto/tex:";
      EDITOR = "emacsclient";
      VISUAL = EDITOR;
      ALTERNATE_EDITOR = "";
    };
  };

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
  };
}
