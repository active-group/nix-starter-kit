# Thunderbird

This module provides thunderbird with the following things already set up:
- AG address book
- AG calendars
- AG eMail

This module currently allows management of AGly calendars via nix.

It provides several usefull options (option prefix `active-group.thunderbird` omitted):

- `enable` enables the module
- `userName` the username used for calender sync
- `profile` the thunderbird profile under which the setup should be done
- `calendars.enableAGCalendars` enables all AG calendars, defaults to `true`
- `calendars.<name>.enable` enable specific AGly calendar, defaults to `calendars.enableAGCalendars`
- `calendars.<name>.name` set the name for the calendar, defaults to the value set in [calendar.nix](./calendars.nix)
- `calendars.<name>.readOnly` wheather the calendar is editable, defaults to `true`
- `calendars.<name>.supressAlarms` wheather alarms on this calendar should be supressed, defaults to `true`
- `calendars.<name>.color` hex code for the color to be used for the calendar
- `calendars.<name>.notifications` a list of string specifying the notifications for the calendar
  - notification can be:
    - `-PTXXM` for a notification XX minutes before the start of the event
    - `-PTXXH` for a notification XX hours before the start of the event
    - `-PXXD` for a notification XX days before the start of the event

The `<name>` of a calendar is the attribute set key in [calendars.nix](./calendars.nix).
When `enableAGCalendars` is set to `true`, all calendars are active unless they are disabled explicitly by setting `calendars.<name>.enable = false`.
If `enableAGCalendars` is set to `false`, all calendars are inactive unless they are enabled explicitly by setting `calendars.<name>.enable = true`.

Add something like the following to the corresponding configuration section in
your `home.nix` file:

```nix
  active-group.thunderbird = {
    enable = true;
    calendars = {
      enableAGCalendars = true;
      felix = {
        readOnly = false;
        suppressAlarms = false;
        color = "#ff2968";
      };
      geburtstage.color = "#0000ff";
      regeltermine.color = "#0000ff";

      bianca-schulungen.enable = false;
      felix-schulungen.enable = false;
      marco-schulungen.enable = false;
      marcus-schulungen.enable = false;
      markus-schulungen.enable = false;
      pr.enable = false;
    };
  };
```
