# zsh

Especially on macOS it might be useful to configure its default shell, `zsh`, to
work well with Nix and maybe dispatch to the easier-to-use-by-default shell `fish`
when used interactively.

(NOTE: if you have an existing `~/.zshrc` file that you wish to keep, don't do the
following; I trust that you should know what you're doing already in this case.)

Install our example `zsh` configuration file as a starting point by copying the
contents of [example-zshrc](./example-zshrc) to `~/.zshrc`. It calls a couple
of pre-installed (after having run `home-manager switch` with this module
enabled) functions to add functionality. You can edit it to your liking.
