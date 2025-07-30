#!/bin/sh
sudo su - <<EOF
source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
nix-channel --remove nixpkgs
nix-channel --add https://nixos.org/channels/nixos-25.05 nixpkgs
nix-channel --update
nix-env -iA nixpkgs.nix
if [ -e /bin/launchctl ]; then
  launchctl kickstart -k system/org.nixos.nix-daemon
fi
EOF

