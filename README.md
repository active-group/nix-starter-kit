# Nix starter kit

## Provisioning a fresh system

- Install the [Nix package manager](https://nixos.org) and enable Flakes
- On the target system, use the provided template to create an initial
  home-manager configuration with batteries included:

```shell
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
nix flake new --template github:active-group/nix-starter-kit ~/.config/home-manager
```

- Adapt `~/.config/home-manager/flake.nix` according to your username and other
  details
- If you wish to use LaTeX with batteries included, then you need to clone the
  `howto` repository to `~/howto` (or configure the path in your `home.nix` according
  to your checkout path). If you already have a working LaTeX setup, you don't
  need to change anything.
- Now execute the following commands from a shell:

```shell
nix run github:active-group/nix-starter-kit#home-manager -- switch
```

### Emacs config

To make use of some common configuration for Emacs that we've written, you can
create a reasonable starting point by coping the contents of
[example-init.el](~/.config/ag-emacs/example-init.el) to `~/.emacs.d/init.el`. Note that
you might have to `mkdir -p ~/.emacs.d` first.

### zsh

Especially on macOS it might be useful to configure its default shell, `zsh`, to
work well with Nix and maybe dispatch to the easier-to-use-by-default shell `fish`
when used interactively.

(NOTE: if you have an existing `~/.zshrc` file that you wish to keep, don't do the
following; I trust that you should know what you're doing already in this case.)

Install our example `zsh` configuration file as a starting point by copying the
contents of [example-zshrc](~/.config/ag-zsh/example-zshrc) to `~/.zshrc`. It calls a couple
of pre-installed (after having run `home-manager switch` with this module
enabled) functions to add functionality. You can edit it to your liking.

### controlling

For the controlling-related software, change `controlling.enable = false` to
`controlling.enable = true`  in `home.nix`.

### Contact management using khard

Configure the module to point to a directory containing vcf files.
The [vcf dir inside the active group addresses
repo](https://gitlab.active-group.de/ag/addresses/-/tree/main/vcf) can be used
for example.

```nix
active-group = {
    khard = {
      enable = true;
      # Example storagePath: /home/<mitarbeity>/ag/addresses/vcf
      storagePath = "/<absolute>/<path>/<to>/<dir>/<with>/<vcf-files>";
    };
  };
```

### Out-of-office notifications via `sieve-connect`

The file [file:message.template](./.config/ag-sieve/message.template) contains a template for
the message you wish to be shown. Copy it somewhere on your own machine (the
module's assumed default location is
`~/.config/home-manager/abwesenheitsnotiz`) and configure the module
accordingly. For instance:

```nix
  active-group.sieve = {
    enable = true;
    userName = "foo.bar@active-group.de";
    messagePath = "<path>/<to>/<abwesenheitsnotiz>";
  };
```

In order to activate the note of absence, execute the installed `ag-sieve`
command:

```shell
ag-sieve activate
```

To deactivate the notifications, execute

```shell
ag-sieve deactivate
```

#### REPL

In case you wish to interact with the REPL mode of `sieve-connect` directly,
you can call `ag-sieve` without any arguments instead.

### Thunderbird

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

      pr.enable = false;
    };
  };
```

### Timetracking

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

#### Scripts for users

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

#### Scripts for admins

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

## Adding packages

We use `nixpkgs` to manage the packages Emacs comes equipped with. If you need
additional packages, use the `additionalEmacsPackages` attribute in `home.nix`.




## Usage

### Adding software

On https://search.nixos.org/packages you can search for packages you'd like to
have available on your system. Add those packages to your `home.nix` in
`home.packages`. Check out [the home-manager
manual](https://nix-community.github.io/home-manager/) or ask someone if in
trouble :)

To "activate" a new configuration, always execute

```shell
home-manager switch
```

## Keeping things up to date

When asked to update your configuration (usually when something has changed in
the starter kit), do the following:

```shell
cd ~/.config/home-manager
nix flake update
home-manager switch
nix run github:active-group/nix-starter-kit#update-daemon
```

See the note on updating the Mac trampolines in
[the README for mac-app-util](file:modules/mac-app-util/README.org::*mac-app-util).

If you see errors related to "sandbox initialization", you might need to turn
off sandboxing temporarily in `/etc/nix/nix.conf`.

## Updating Nixpkgs (for admins)

```shell
nix flake update
```

If there's a new Nix version, consider updating the version number in
`flake.nix`. Then `git push`.

# Local Variables:
# fill-column: 80
# End:
