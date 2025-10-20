# Timetracking

Add something like the following to the corresponding configuration section in
your `home.nix` file:

```nix
  active-group.timetracking = {
    enable = true;
    timetracking-token = "<path-to-timetracking-api-token>";
    timereporting-token = "<path-to-timereporting-api-token>";
  };
```

## Scripts for users

The `timetracking` module provides all the scripts from `active-timetracking`.

If both `timetracking-token` and `timereporting-token` options are set, the
module will additionally provide the wrapped scripts

- `tt-sync`
- `tt-import-labor`
- `tt-import-billable`
- `tt-timereporting` (`kimai_report` for `timereporting`)
- `tt-timetracking` (`kimai_report` for `timetracking`)

which have the API tokens and API URLs already set.

## Scripts for admins

If both `timetracking-admin-token` and `timereporting-admin-token` options are
set, the module will additionally provide the wrapped scripts

- `tt-admin-sync`
- `tt-admin-export-to-stundenzettel`
- `tt-admin-delete-old-records`
- `tt-admin-timereporting`
- `tt-admin-timetracking`

which have the API tokens and API URLs already set.
