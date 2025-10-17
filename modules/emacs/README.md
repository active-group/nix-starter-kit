# Emacs

To use this module, add it to your `additionalModules` in `home.nix`:

```nix
additionalModules = settings: [
  (import ./emacs settings)
]
```

Then use `home-manager switch` to install Emacs on your system.

To make use of some common configuration that we've written, you can create a
reasonable starting point by coping the contents of
[example-init.el](./ag-emacs/example-init.el) to `~/.emacs.d/init.el`. Note
that you might have to `mkdir -p ~/.emacs/.d` first.

## Adding packages

We use `nixpkgs` to manage the packages Emacs comes equipped with. If you need
additional packages, use the `additionalEmacsPackages` attribute in `home.nix`.
