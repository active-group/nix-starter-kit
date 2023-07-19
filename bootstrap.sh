#!/usr/bin/env bash

set -e

echo "Starting installation of Nix"
echo
sh <(curl -L https://nixos.org/nix/install)

echo "Enabling Nix flakes"
echo
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf

# Use an absolute path, as right after installation the appropriate
# environment is not sourced yet
nix=/nix/var/nix/profiles/default/bin/nix

# Execute a dummy nix command to 1) test the installation, and 2) to
# have nix create necessary symlinks without which it will fail on the
# next step.  This needs to be something other than `nix run`
# apparently.
$nix shell nixpkgs#cowsay -c cowsay Everything up and running, nice!

# Install the home-manager configuration
$nix run home-manager/release-23.05 switch

echo "Everything should be installed now!"
