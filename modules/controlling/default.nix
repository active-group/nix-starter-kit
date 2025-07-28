{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.active-group.controlling.enable = lib.mkEnableOption "controlling";

  config = lib.mkIf config.active-group.controlling.enable {
    home.packages =
      let
        activeControlling = builtins.fetchGit {
          url = "ssh://git@gitlab.active-group.de:1022/ag/active-accounting.git";
          rev = "4589d55435b7c92c5912d3c4132fe29f596042be";
        };
      in
      [ (import "${activeControlling}/default.nix").outputs.packages.${pkgs.stdenv.system}.default ];
  };
}
