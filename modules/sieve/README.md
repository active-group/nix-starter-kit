# Out-of-office notifications via `sieve-connect`

The file [file:message.template](./message.template) contains a template for
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
