{ pkgs, ... }:
{ home.packages =
    let activeControlling = builtins.fetchGit {
          url = "ssh://git@gitlab.active-group.de:1022/ag/buchhaltung-controlling.git";
          rev = "80fef43d0af028bbaf35ad737e96b09d308246a9";
        };
    in [ (import "${activeControlling}/default.nix").outputs.packages.${pkgs.stdenv.system}.default ];
}
