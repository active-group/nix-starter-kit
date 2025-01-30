settings:
{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.git = {
    enable = true;
    userName = settings.userFullName;
    userEmail = settings.email;
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
    };
  };
}
