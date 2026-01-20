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
    timetracking-url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://timetracking.active-group.de/api";
      description = "URL to API enpoint of timetracking instance";
    };
    timetracking-token = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file containing your timetracking API token";
    };
    timetracking-admin-token = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file containing the admin timetracking API token";
    };

    arbeitszeiten-url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://arbeitszeiten.active-group.de/api";
      description = "URL to API enpoint of arbeitszeiten instance";
    };
    arbeitszeiten-token = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file containing your arbeitszeiten API token";
    };
    arbeitszeiten-admin-token = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file containing the admin arbeitszeiten API token";
    };

    abrechenbare-zeiten-url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "https://abrechenbare-zeiten.active-group.de/api";
      description = "URL to API enpoint of abrechenbare-zeiten instance";
    };
    abrechenbare-zeiten-token = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file containing your abrechenbare-zeiten API token";
    };
    abrechenbare-zeiten-admin-token = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file containing the admin abrechenbare-zeiten API token";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        tt = inputs.active-timetracking.packages.${pkgs.stdenv.hostPlatform.system}.default;

        wrap-token-token-script =
          name: script: token1: token2:
          pkgs.writeShellScriptBin name ''
            TOKEN1=$(cat ${token1})
            TOKEN2=$(cat ${token2})
            ${script} ''${TOKEN1} ''${TOKEN2} $@
          '';
        wrap-url-token-token-token-script =
          name: script: url: token1: token2: token3:
          pkgs.writeShellScriptBin name ''
            TT_SYNC_SOURCE_URL=${url}
            TOKEN1=$(cat ${token1})
            TOKEN2=$(cat ${token2})
            TOKEN3=$(cat ${token3})
            export TT_SYNC_SOURCE_URL
            ${script} ''${TOKEN1} ''${TOKEN2} ''${TOKEN3} $@
            unset TT_SYNC_SOURCE_URL
          '';
        wrap-token-script =
          name: script: token:
          pkgs.writeShellScriptBin name ''
            TOKEN=$(cat ${token})
            ${script} ''${TOKEN} $@
          '';
        wrap-url-token-script =
          name: script: url: token:
          pkgs.writeShellScriptBin name ''
            API=${url}
            TOKEN=$(cat ${token})
            ${script} ''${API} ''${TOKEN} $@
          '';
        wrap-kimai-report =
          name: url: token:
          pkgs.writeShellScriptBin name ''
            COMMAND="$1"
            REMAINING_ARGS=("''${@:2}")
            TOKEN=$(cat ${token})
            ${tt}/bin/kimai_report "''${COMMAND}" ${url} ''${TOKEN} "''${REMAINING_ARGS[@]}"
          '';
        wrap-kimai-config-sync =
          name: timetracking-admin-token: arbeitszeiten-admin-token: abrechenbare-zeiten-admin-token:
          pkgs.writeShellScriptBin name ''
            TIMETRACKING_APIKEY=$(cat ${timetracking-admin-token})
            ARBEITSZEITEN_APIKEY=$(cat ${arbeitszeiten-admin-token})
            ABRECHENBARE_ZEITEN_APIKEY=$(cat ${abrechenbare-zeiten-admin-token})

            CMD=''${1-diff}
            ARBEITSZEITEN_EDN=''${2-arbeitszeiten.edn}
            ABRECHENBARE_ZEITEN_EDN=''${3-abrechenbare-zeiten.edn}

            USAGE="Usage: $(basename $0) <cmd:diff|sync> </path/to/arbeitszeiten.edn> </path/to/abrechenbare-zeiten.edn>"
            ERROR=""

            if [ ! -f ''${ARBEITSZEITEN_EDN} ]; then
               ERROR="''${ERROR}Error: ''${ARBEITSZEITEN_EDN} not found.\n"
            fi

            if [ ! -f ''${ABRECHENBARE_ZEITEN_EDN} ]; then
               ERROR="''${ERROR}Error: ''${ABRECHENBARE_ZEITEN_EDN} not found.\n"
            fi

            if [ ! -z "''${ERROR}" ]; then
               echo -e "''${ERROR}"
               echo "''${USAGE}"
               exit -1
            fi

            ${tt}/bin/kimai-config-sync "''${CMD}" -u ${cfg.timetracking-url} -k "''${TIMETRACKING_APIKEY}" -c "''${ABRECHENBARE_ZEITEN_EDN}" -c "''${ARBEITSZEITEN_EDN}"
            ${tt}/bin/kimai-config-sync "''${CMD}" -u ${cfg.abrechenbare-zeiten-url} -k "''${ABRECHENBARE_ZEITEN_APIKEY}" -c "''${ABRECHENBARE_ZEITEN_EDN}"
            ${tt}/bin/kimai-config-sync "''${CMD}" -u ${cfg.arbeitszeiten-url} -k "''${ARBEITSZEITEN_APIKEY}" -c "''${ARBEITSZEITEN_EDN}"
          '';
        tt-sync = wrap-url-token-token-token-script "tt-sync" "${tt}/bin/sync.sh" "${cfg.timetracking-url
        }" "${cfg.timetracking-token}" "${cfg.arbeitszeiten-token}" "${cfg.abrechenbare-zeiten-token}";
        tt-import-arbeitszeiten =
          wrap-url-token-script "tt-import-arbeitszeiten" "${tt}/bin/import-arbeitszeiten.sh"
            "${cfg.arbeitszeiten-url}"
            "${cfg.arbeitszeiten-token}";
        tt-import-abwesenheiten =
          wrap-url-token-script "tt-import-abwesenheiten" "${tt}/bin/import-abwesenheiten.sh"
            "${cfg.arbeitszeiten-url}"
            "${cfg.arbeitszeiten-token}";
        tt-import-abrechenbare-zeiten =
          wrap-url-token-script "tt-import-abrechenbare-zeiten" "${tt}/bin/import-abrechenbare-zeiten.sh"
            "${cfg.abrechenbare-zeiten-url}"
            "${cfg.abrechenbare-zeiten-token}";
        tt-report-timetracking = wrap-kimai-report "tt-report-timetracking" "${cfg.timetracking-url
        }" "${cfg.timetracking-token}";
        tt-report-arbeitszeiten = wrap-kimai-report "tt-report-arbeitszeiten" "${cfg.arbeitszeiten-url
        }" "${cfg.arbeitszeiten-token}";
        tt-report-abrechenbare-zeiten =
          wrap-kimai-report "tt-report-abrechenbare-zeiten" "${cfg.abrechenbare-zeiten-url}"
            "${cfg.abrechenbare-zeiten-token}";

        tt-admin-sync =
          wrap-url-token-token-token-script "tt-admin-sync" "${tt}/bin/sync.sh" "${cfg.timetracking-url}"
            "${cfg.timetracking-admin-token}"
            "${cfg.arbeitszeiten-admin-token}"
            "${cfg.abrechenbare-zeiten-admin-token}";
        tt-admin-delete-old-records =
          wrap-token-token-script "tt-admin-delete-old-records" "${tt}/bin/delete-old-records.sh"
            "${cfg.arbeitszeiten-admin-token}"
            "${cfg.abrechenbare-zeiten-admin-token}";
        tt-admin-export-to-stundenzettel =
          wrap-token-script "tt-admin-export-to-stundenzettel" "${tt}/bin/export-to-stundenzettel.sh"
            "${cfg.abrechenbare-zeiten-admin-token}";
        tt-admin-show-missing-arbeitszeiten =
          wrap-token-script "tt-admin-show-missing-arbeitszeiten" "${tt}/bin/show-missing-arbeitszeiten.sh"
            "${cfg.arbeitszeiten-admin-token}";
        tt-admin-show-arbeitszeiten-compliance =
          wrap-token-script "tt-admin-show-arbeitszeiten-compliance" "${tt}/bin/show-arbeitszeiten-compliance.sh"
            "${cfg.arbeitszeiten-admin-token}";
        tt-admin-import-arbeitszeiten =
          wrap-url-token-script "tt-admin-import-arbeitszeiten" "${tt}/bin/import-arbeitszeiten.sh"
            "${cfg.arbeitszeiten-url}"
            "${cfg.arbeitszeiten-admin-token}";
        tt-admin-import-abwesenheiten =
          wrap-url-token-script "tt-admin-import-abwesenheiten" "${tt}/bin/import-abwesenheiten.sh"
            "${cfg.arbeitszeiten-url}"
            "${cfg.arbeitszeiten-admin-token}";
        tt-admin-import-abrechenbare-zeiten =
          wrap-url-token-script "tt-admin-import-abrechenbare-zeiten"
            "${tt}/bin/import-abrechenbare-zeiten.sh"
            "${cfg.abrechenbare-zeiten-url}"
            "${cfg.abrechenbare-zeiten-admin-token}";
        tt-admin-report-timetracking =
          wrap-kimai-report "tt-admin-report-timetracking" "${cfg.timetracking-url}"
            "${cfg.timetracking-admin-token}";
        tt-admin-report-arbeitszeiten =
          wrap-kimai-report "tt-admin-report-arbeitszeiten" "${cfg.arbeitszeiten-url}"
            "${cfg.arbeitszeiten-admin-token}";
        tt-admin-report-abrechenbare-zeiten =
          wrap-kimai-report "tt-admin-report-abrechenbare-zeiten" "${cfg.abrechenbare-zeiten-url}"
            "${cfg.abrechenbare-zeiten-admin-token}";

        tt-admin-kimai-config-sync =
          wrap-kimai-config-sync "tt-admin-kimai-config-sync" "${cfg.timetracking-admin-token}"
            "${cfg.arbeitszeiten-admin-token}"
            "${cfg.abrechenbare-zeiten-admin-token}";

      in
      (
        if
          cfg.timetracking-token != null
          && cfg.arbeitszeiten-token != null
          && cfg.abrechenbare-zeiten-token != null
        then
          [
            tt-sync
          ]
        else
          [ ]
      )
      ++ (
        if cfg.timetracking-token != null then
          [
            tt-report-timetracking
          ]
        else
          [ ]
      )
      ++ (
        if cfg.arbeitszeiten-token != null then
          [
            tt-import-arbeitszeiten
            tt-import-abwesenheiten
            tt-report-arbeitszeiten
          ]
        else
          [ ]
      )
      ++ (
        if cfg.abrechenbare-zeiten-token != null then
          [
            tt-import-abrechenbare-zeiten
            tt-report-abrechenbare-zeiten
          ]
        else
          [ ]
      )
      ++ (
        if
          cfg.timetracking-admin-token != null
          && cfg.arbeitszeiten-admin-token != null
          && cfg.abrechenbare-zeiten-admin-token != null
        then
          [
            tt-admin-sync
            tt-admin-kimai-config-sync
          ]
        else
          [ ]
      )
      ++ (
        if cfg.timetracking-admin-token != null then
          [
            tt-admin-report-timetracking
          ]
        else
          [ ]
      )
      ++ (
        if cfg.arbeitszeiten-admin-token != null then
          [
            tt-admin-report-arbeitszeiten
            tt-admin-import-arbeitszeiten
            tt-admin-import-abwesenheiten
            tt-admin-show-missing-arbeitszeiten
            tt-admin-show-arbeitszeiten-compliance
          ]
        else
          [ ]
      )
      ++ (
        if cfg.abrechenbare-zeiten-admin-token != null then
          [
            tt-admin-export-to-stundenzettel
            tt-admin-report-abrechenbare-zeiten
            tt-admin-import-abrechenbare-zeiten
          ]
        else
          [ ]
      )
      ++ (
        if cfg.arbeitszeiten-admin-token != null && cfg.abrechenbare-zeiten-admin-token != null then
          [
            tt-admin-delete-old-records
          ]
        else
          [ ]
      )
      ++ [ tt ];
  };
}
