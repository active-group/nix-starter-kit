{ config, lib, ... }:

{
  options.active-group.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf config.active-group.zsh.enable {
    home.file.".config/zsh/ag.zsh".source = ./ag.zsh;
  };
}
