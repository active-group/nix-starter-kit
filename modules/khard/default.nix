{
  config,
  lib,
  ...
}:

let
  cfg = config.active-group.khard;
  pwCommandOrFileMessage = "The option passwordCommand or passwordFile must be configured.";
  pwFileDefaultCommand = [
    "cat"
    cfg.passwordFile
  ];
in
{
  options.active-group.khard = {
    enable = lib.mkEnableOption "khard";
    passwordFile = lib.mkOption {
      type = lib.nullOr lib.str;
    };
    passwordCommand = lib.mkOption {
      type = lib.nullOr lib.listOfStr;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !isNull cfg.passwordCommand || !isNull cfg.passwordFile;
        message = pwCommandOrFileMessage;
      }
    ];
    programs.khard.enable = true;
    contact.accounts.ag = {
      remote = {
        type = "carddav";
        url = "https://calendar.active-group.de/addressbook/cdf53880-4c47-8484-5da3-4967cc565ece/";
        userName = cfg.userName;
        passwordCommand =
          if (!isNull cfg.passwordCommand) then
            cfg.passwordCommand
          else if (!isNull cfg.passwordFile) then
            pwFileDefaultCommand
          else
            abort pwCommandOrFileMessage;
      };
      khard = {
        enable = true;
      };
    };
  };
}
