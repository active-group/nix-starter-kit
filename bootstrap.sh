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

# This directory is not automatically created by the Nix installer,
# but is needed by home-manager
mkdir -p ~/.local/state/nix/profiles

# Set the username
if [ "$(uname -s)" = "Darwin" ]; then
    sed -i "" "s/<USERNAME>/$(whoami)/" flake.nix
else
    sed -i "s/<USERNAME>/$(whoami)/" flake.nix
fi

# Install the home-manager configuration
$nix run home-manager/release-23.05 switch

echo "Everything should be installed now!"
