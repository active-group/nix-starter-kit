{ lib, ... }:
{
  options.active-group.ldap = {
    userName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "LDAP username";
    };
    fullName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Full name";
    };
    email = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "eMail address";
    };
    phoneNumber = lib.mkOption {
      type = lib.types.nullOr lib.types.nonEmptyStr;
      description = "AG phone number";
    };
  };
}
