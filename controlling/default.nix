{ pkgs, ... }:
{ home.packages =
    let activeControlling = builtins.fetchGit {
          url = "ssh://git@gitlab.active-group.de:1022/ag/buchhaltung-controlling.git";
          rev = "d9dadb3a5313368c177826e8b26a7e5330e543e9";
        };
    in [ (import "${activeControlling}/default.nix").outputs.packages.${pkgs.stdenv.system}.backend ];
}
