{ pkgs, ... }:

{
  home.packages =
    let
      activeControlling = builtins.fetchGit {
        url = "ssh://git@gitlab.active-group.de:1022/ag/active-accounting.git";
        rev = "7b52eb44115728075dffde2328639fda1546e421";
      };
    in
    [ (import "${activeControlling}/default.nix").outputs.packages.${pkgs.stdenv.system}.default ];
}
