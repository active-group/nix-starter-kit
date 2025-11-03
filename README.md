# Nix starter kit

## Provisioning a fresh system

- Install the [Nix package manager](https://nixos.org) and enable Flakes
- On the target system, use the provided template to create an initial
  home-manager configuration with batteries included:

```shell
mkdir -p ~/.config
nix flake new --template github:active-group/nix-starter-kit ~/.config/home-manager
```

- Adapt `~/.config/home-manager/flake.nix` according to your username and other
  details
- To configure modules like Emacs, `zsh`, or others, check the README files in
  their respective subdirectories in this repository
- If you wish to use LaTeX with batteries included, then you need to clone the
  `howto` repository to `~/howto` (or configure the path in your `home.nix` according
  to your checkout path). If you already have a working LaTeX setup, you don't
  need to change anything.
- Now execute the following commands from a shell:

```shell
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
nix run github:active-group/nix-starter-kit#home-manager -- switch
```

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
