#!/usr/bin/env bash

set -e

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

# Install the home-manager configuration
$nix run home-manager/release-25.05 switch

echo "Everything should be installed now!"
