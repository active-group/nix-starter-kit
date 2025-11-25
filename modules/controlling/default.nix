{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  options.active-group.controlling.enable = lib.mkEnableOption "controlling";

  config = lib.mkIf config.active-group.controlling.enable {
    home.packages = [
      inputs.active-accounting.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
