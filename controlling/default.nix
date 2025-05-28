{ pkgs, ... }:

{
  home.packages =
    let
      activeControlling = builtins.fetchGit {
        url = "ssh://git@gitlab.active-group.de:1022/ag/active-accounting.git";
        rev = "5cc6a31c3fa0d44fff57400d2b86bba966c9451c";
      };
    in
    [ (import "${activeControlling}/default.nix").outputs.packages.${pkgs.stdenv.system}.default ];
}
