# Timetracking

```nix
  active-group.timetracking = {
    enable = true;
    timetracking-token = "<path-to-timetracking-api-token>";
    timereporting-token = "<path-to-timereporting-api-token>";
  };
```

## Scripts
The timetracking module provides all the scripts from =active-timetracking=.
If both `timetracking-token` and `timereporting-token` options are set,
the module will additionally provide the wrapped scripts
- `tt-sync`
- `tt-import-labor`
- `tt-import-billable`

which have the API tokens and API URLs already set.
