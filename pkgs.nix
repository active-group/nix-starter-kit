let
#  settings = import ./user-settings.nix;
  # NOTE: When updating the setup within the same release channel, put its
  # latest commit here.
  # NixOS 25.05 as of 2025-05-27
  nixpkgsRev = "101f54e74e5b9969bba239480e2e77c4aac0c3e0";
  nixpkgs =
    # settings.nixpkgs or
      (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsRev}.tar.gz";
      sha256 = "10y128y7y93p88w7s2d65333yk551jxdg8qdv757yby223jmq20p";
    });
in nixpkgs
