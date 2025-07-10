{ writeShellScriptBin }:

writeShellScriptBin "update-daemon" ''
  sudo su - <<EOF
  set -e
  source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
  nix-channel --remove nixpkgs || true
  nix-channel --add https://nixos.org/channels/nixos-25.05 nixpkgs
  nix-channel --update
  nix-env -iA nixpkgs.nix
  if [ -e /bin/launchctl ]; then
    launchctl kickstart -k system/org.nixos.nix-daemon
  else
    systemctl restart nix-daemon.service
  fi
  EOF
''
