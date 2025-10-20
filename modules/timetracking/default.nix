{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.active-group.timetracking;
in
{
  options.active-group.timetracking = {
    enable = lib.mkEnableOption "timetracking";
    timetracking-token = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file containing your timetracking API token";
    };
    timereporting-token = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file containing your timereporting API token";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        tt = inputs.active-timetracking.packages.${pkgs.system}.default;

        tokens-defined = cfg.timetracking-token != null && cfg.timereporting-token != null;
        wrap-script =
          name: script:
          pkgs.writeShellScriptBin name ''
            TIME_TRACKING_TOKEN=$(cat ${cfg.timetracking-token})
            TIME_REPORTING_TOKEN=$(cat ${cfg.timereporting-token})
            TIME_REPORTING_API="https://timereporting.active-group.de/api"
            ${script} $@
          '';

        tt-sync = wrap-script "tt-sync" "${tt}/bin/sync.sh $TIME_TRACKING_TOKEN $TIME_REPORTING_TOKEN";
        tt-import-labor = wrap-script "tt-import-labor" "${tt}/bin/import-labor.sh $TIME_REPORTING_API $TIME_REPORTING_TOKEN";
        tt-import-billable = wrap-script "tt-import-billable" "${tt}/bin/import-billable.sh $TIME_REPORTING_API $TIME_REPORTING_TOKEN";
        additionalScripts =
          if tokens-defined then
            [
              tt-sync
              tt-import-labor
              tt-import-billable
            ]
          else
            [ ];
      in
      additionalScripts ++ [ tt ];
  };
}
