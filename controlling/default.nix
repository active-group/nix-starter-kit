{ pkgs, ... }:
{ home.packages =
    let activeControlling = builtins.fetchGit {
          url = "ssh://git@gitlab.active-group.de:1022/ag/buchhaltung-controlling.git";
          rev = "401c147d635b3db480968562ac674408ba3ed20d";
        };
    in [ (import "${activeControlling}/default.nix").outputs.packages.${pkgs.stdenv.system}.default ];
}
