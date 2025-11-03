{ config, lib, ... }:

let
  cfg = config.active-group.git;
in
{
  options.active-group.git = {
    enable = lib.mkEnableOption "git";
    userName = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };
    userEmail = lib.mkOption {
      type = lib.types.nonEmptyStr;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      ignores = [
        ".DS_Store"
        "*~"
        "\\#*\\#"
        ".\\#*"
      ];
      extraConfig = {
        core.askPass = "";
        init.defaultBranch = "main";
        submodule.recurse = true;
        pull.rebase = false;
      };
    };
  };
}
