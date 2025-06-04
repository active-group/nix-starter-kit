{ pkgs, ... }:

{
  home.packages =
    let
      activeControlling = builtins.fetchGit {
        url = "ssh://git@gitlab.active-group.de:1022/ag/active-accounting.git";
        rev = "15db12f74aec7fe4f9ad2841755126da7c51a2cb";
      };
    in
    [ (import "${activeControlling}/default.nix").outputs.packages.${pkgs.stdenv.system}.default ];
}
