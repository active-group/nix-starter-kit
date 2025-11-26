# Timetracking

Add something like the following to the corresponding configuration section in
your `home.nix` file:

```nix
  active-group.timetracking = {
    enable = true;
    timetracking-token = "<path-to-timetracking-api-token>";
    arbeitszeiten-token = "<path-to-arbeitszeiten-api-token>";
    abrechenbare-zeiten-token = "<path-to-abrechenbare-zeiten-api-token>";
  };
```

## Scripts for users

The `timetracking` module provides all the scripts from `active-timetracking`.

If `timetracking-token` and `arbeitszeiten-token` and
`abrechenbare-zeiten-token` options are set, the module will additionally
provide the wrapped scripts

- `tt-sync`
- `tt-import-arbeitszeiten`
- `tt-import-abwesenheiten`
- `tt-import-abrechenbare-zeiten`
- `tt-report-timetracking`
- `tt-report-arbeitszeiten`
- `tt-report-abrechenbare-zeiten`

which have the API tokens and API URLs already set.

## Scripts for admins

If the admin tokens `timetracking-admin-token` and `arbeitszeiten-admin-token`
and `abrechenbare-zeiten-admin-token` options are set, the module will
additionally provide the wrapped scripts

- `tt-admin-sync`
- `tt-admin-export-to-stundenzettel`
- `tt-admin-delete-old-records`
- `tt-report-report-timetracking`
- `tt-report-report-arbeitszeiten`
- `tt-report-report-abrechenbare-zeiten`

which have the API tokens and API URLs already set.
