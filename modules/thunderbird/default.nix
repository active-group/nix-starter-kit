{
  config,
  lib,
  ...
}:
let
  cfg = config.active-group.thunderbird;

  calendars = import ./calendars.nix;
  custom = import ./custom.nix { inherit lib; };

  enabledCalendars = lib.attrsets.filterAttrs (
    calName: cal: cfg.calendars.${calName}.enable
  ) calendars;

  calendarNames = lib.attrsets.attrNames calendars;
  calendarCount = lib.length calendarNames;

  colors =
    if cfg.calendars.enableAGCalendars then
      lib.mergeAttrsList (
        lib.imap0 (i: name: {
          ${name} = {
            color = custom.grayscale i calendarCount;
          };
        }) (lib.filter (calName: cfg.calendars.${calName}.enable) calendarNames)
      )
    else
      { };

  mkCal =
    {
      url,
      extra ? { },
    }:
    {
      remote = {
        type = "caldav";
        inherit url;
        inherit (cfg) userName;
      };
      thunderbird = {
        enable = true;
        settings =
          id: lib.mapAttrs' (k: v: lib.nameValuePair "calendar.registry.calendar_${id}.${k}" v) extra;
      };
    };

  calendarOpts = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = cfg.calendars.enableAGCalendars;
          description = "Wheather to enable the calendar.";
        };
        name = lib.mkOption {
          type = lib.types.nullOr lib.types.nonEmptyStr;
          description = "Display name for the calendar";
        };
        readOnly = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Wheather the calender should be editable.";
        };
        suppressAlarms = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Wheather the calender should notify on events.";
        };
        color = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "Color for the calendar.";
        };
      };
    };
  };
in
{
  options.active-group.thunderbird = {
    enable = lib.mkEnableOption "thunderbird";
    userName = lib.mkOption {
      type = lib.types.str;
      description = "LDAP username used to sync calendars.";
    };
    profile = lib.mkOption {
      type = lib.types.str;
      default = "ag";
      description = "The profile to be used for configuration.";
    };

    calendars = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enableAGCalendars = lib.mkEnableOption {
            default = true;
          };
        }
        // (lib.attrsets.genAttrs' calendarNames (calName: {
          name = calName;
          value = calendarOpts;
        }));
      };
    };
  };

  config = lib.mkIf cfg.enable {
    accounts.calendar.accounts =
      lib.attrsets.zipAttrsWith
        (
          name: values:
          let
            calendarInfo = builtins.elemAt values 0;
            calendar = custom.mergeAttrsIgnoringNulls values;
          in
          mkCal {
            url = calendarInfo.url;
            extra = calendar;
          }
        )
        (
          let
            calendarOptions = lib.attrsets.filterAttrs (n: v: cfg.calendars.${n}.enable) (
              builtins.removeAttrs cfg.calendars [ "enableAGCalendars" ]
            );
          in
          [
            enabledCalendars
            colors
            calendarOptions
          ]
        );

    programs.thunderbird = {
      enable = true;
      profiles.${cfg.profile}.isDefault = true;
    };
  };
}
