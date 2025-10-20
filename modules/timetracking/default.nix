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
    timetracking-url =  lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://timetracking.active-group.de/api";
      description = "URL to API enpoint of timetracking instance";
    };
    timereporting-url =  lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://timereporting.active-group.de/api";
      description = "URL to API enpoint of timereporting instance";
    };
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
    timetracking-admin-token = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file containing the admin timetracking API token";
    };
    timereporting-admin-token = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file containing the admin timereporting API token";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        tt = inputs.active-timetracking.packages.${pkgs.system}.default;

        wrap-token-token-script =
          name: script: timetracking-token: timereporting-token:
          pkgs.writeShellScriptBin name ''
            TIME_TRACKING_TOKEN=$(cat ${timetracking-token})
            TIME_REPORTING_TOKEN=$(cat ${timereporting-token})
            ${script} ''${TIME_TRACKING_TOKEN} ''${TIME_REPORTING_TOKEN} $@
          '';
        wrap-url-token-script =
          name: script: url: token:
          pkgs.writeShellScriptBin name ''
            TIME_REPORTING_API=${url}
            TIME_REPORTING_TOKEN=$(cat ${token})
            ${script} ''${TIME_REPORTING_API} ''${TIME_REPORTING_TOKEN} $@
          '';
        wrap-kimai-report =
          name: url: token:
          pkgs.writeShellScriptBin name ''
            COMMAND="$1"
            REMAINING_ARGS=("''${@:2}")
            TIME_REPORTING_TOKEN=$(cat ${token})
            ${tt}/bin/kimai_report "''${COMMAND}" ${url} ''${TIME_REPORTING_TOKEN} "''${REMAINING_ARGS[@]}"
          '';

        tt-sync = wrap-token-token-script "tt-sync" "${tt}/bin/sync.sh" "${cfg.timetracking-token}" "${cfg.timereporting-token}";
        tt-import-labor = wrap-url-token-script "tt-import-labor" "${tt}/bin/import-labor.sh" "${cfg.timereporting-url}" "${cfg.timereporting-token}";
        tt-import-billable = wrap-url-token-script "tt-import-billable" "${tt}/bin/import-billable.sh"  "${cfg.timereporting-url}" "${cfg.timereporting-token}";
        tt-timetracking = wrap-kimai-report "tt-timetracking"  "${cfg.timetracking-url}" "${cfg.timetracking-token}";
        tt-timereporting = wrap-kimai-report "tt-timereporting"  "${cfg.timereporting-url}" "${cfg.timereporting-token}";

        tt-admin-sync = wrap-token-token-script "tt-admin-sync" "${tt}/bin/sync.sh" "${cfg.timetracking-admin-token}" "${cfg.timereporting-admin-token}";
        tt-admin-delete-old-records = wrap-url-token-script "tt-admin-delete-old-records" "${tt}/bin/delete-old-records.sh" "${cfg.timereporting-url}" "${cfg.timereporting-admin-token}";
        tt-admin-export-to-stundenzettel = wrap-url-token-script "tt-admin-export-to-stundenzettel" "${tt}/bin/export-to-stundenzettel.sh" "${cfg.timereporting-url}" "${cfg.timereporting-admin-token}";
        tt-admin-timetracking = wrap-kimai-report "tt-admin-timetracking" "${cfg.timetracking-url}" "${cfg.timetracking-admin-token}";
        tt-admin-timereporting = wrap-kimai-report "tt-admin-timereporting" "${cfg.timereporting-url}" "${cfg.timereporting-admin-token}";

      in
        (if cfg.timetracking-token != null && cfg.timereporting-token != null then
          [
            tt-sync
          ]
         else
           [ ])
        ++
        (if cfg.timetracking-token != null then
          [
            tt-import-labor
            tt-import-billable
            tt-timetracking
          ]
         else
           [ ])
        ++
        (if cfg.timereporting-token != null then
          [
            tt-timereporting
          ]
         else
           [ ])
        ++
        (if cfg.timetracking-admin-token != null && cfg.timereporting-admin-token != null then
          [
            tt-admin-sync
          ]
         else
           [ ])
        ++
        (if cfg.timetracking-admin-token != null then
          [
            tt-admin-timetracking
          ]
         else
           [ ])
        ++
        (if cfg.timereporting-admin-token != null then
          [
            tt-admin-delete-old-records
            tt-admin-export-to-stundenzettel
            tt-admin-timereporting
          ]
         else
           [ ])
        ++ [ tt ];
  };
}
