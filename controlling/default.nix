{ pkgs, ... }:

{
  home.packages =
    let
      activeControlling = builtins.fetchGit {
        url = "ssh://git@gitlab.active-group.de:1022/ag/buchhaltung-controlling.git";
        rev = "00e4c8cd5465d1e19be30dfcf8a56801c3e3ab9f";
      };
    in
    [ (import "${activeControlling}/default.nix").outputs.packages.${pkgs.stdenv.system}.default ];
}
