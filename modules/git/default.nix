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
      ignores = [
        ".DS_Store"
        "*~"
        "\\#*\\#"
        ".\\#*"
      ];
      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        core.askPass = "";
        init.defaultBranch = "main";
        submodule.recurse = true;
        pull.rebase = false;
      };
    };
  };
}
