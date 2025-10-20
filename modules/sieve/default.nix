{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.active-group.sieve;
in
{
  options.active-group.sieve = {
    enable = lib.mkEnableOption "git";
    userName = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };
    messagePath = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Path to a note of absence (sieve script, relative to your home directory)";
      default = ".config/home-manager/abwesenheitsnotiz";
    };
  };

  config =
    let
      localSieve = "${config.home.homeDirectory}/${cfg.messagePath}";
      remoteSieve = baseNameOf cfg.messagePath;
      uploadAndActivate = pkgs.writeText "upload_and_activate" ''
        upload "${localSieve}"
        activate "${remoteSieve}"
      '';
      sieveCmd = "${lib.getExe pkgs.sieve-connect} -s mail.active-group.de -u ${cfg.userName}";
      ag-sieve = pkgs.writeShellScriptBin "ag-sieve" ''
        set -e

        case "$1" in
          "activate")
            if [ ! -f "${localSieve}" ]; then
              echo "Expected '${localSieve}' to exist!"
              exit 1
            fi
            ${sieveCmd} --exec ${uploadAndActivate}
            echo
            echo "------------------------------------------------------------"
            echo "    The following out-of-office message is now *active*:"
            echo "------------------------------------------------------------"
            echo
            cat "${localSieve}"
            ;;
          "deactivate")
            ${sieveCmd} --deactivate
            echo "----------------------------------------------------"
            echo "    Out-of-office message has been *deactivated*"
            echo "----------------------------------------------------"
            ;;
          "")
            ${sieveCmd}
            ;;
          *)
            echo "Usage: ag-sieve [activate|deactivate]"
        esac
      '';
    in
    lib.mkIf cfg.enable {
      home.packages = [ ag-sieve ];
    };
}
