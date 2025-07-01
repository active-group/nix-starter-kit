settings:
{ lib, pkgs, ... }:

let
  # Assumption is that this is the version of the release channel from which
  # nixpkgsRev comes. NOTE: When changing the release version, the bootstrapping
  # script and CI definition need to be adapted accordingly!
  stateVersion = settings.stateVersion or "24.11";
  # NOTE: When updating the setup within the same release channel, put its
  # latest commit here.
  # NixOS 25.05 as of 2025-05-27
  inherit (settings) username;
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
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
    git = {
      enable = true;
      userName = settings.userFullName;
      userEmail = settings.email;
    };
  };
}
