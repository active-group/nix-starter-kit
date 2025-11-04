{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.active-group.mac-app-util;
in
{
  options.active-group.mac-app-util.enable = lib.mkEnableOption "mac-app-util";

  config = lib.mkIf cfg.enable {
    targets.darwin.mac-app-util.enable = true;

    # this belongs with mac-app-util (but difficult to do there) delete the Mac
    # trampolines so they get re-created, which sometimes fixes problems
    home.activation = {
      ${if pkgs.stdenv.isDarwin then "deleteMacAppTrampolines" else null} = lib.hm.dag.entryBefore [
        "trampolineApps"
      ] ''$DRY_RUN_CMD rm -rf "$HOME/Applications/Home Manager Trampolines"'';
    };
  };
}
