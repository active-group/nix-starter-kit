{
  description = "A simple nix-starter-kit powered user setup";

  inputs = {
    nix-starter-kit.url = "github:active-group/nix-starter-kit?ref=flake-o-mania";
  };

  outputs =
    { self, nix-starter-kit }:
    let
      # FIXME
      system = "x86_64-linux";
      identity-settings = {
        username = "sperber";
        userFullName = "Mike Sperber";
        email = "sperber@deinprogramm.de";
      };
      user-settings = identity-settings // {
        additionalPackages = pkgs: [ ];
        additionalModules = settings: [ ];
      };
    in
    {
      homeConfigurations.${user-settings.username} =
        nix-starter-kit.lib.make-default-home-manager-config system user-settings;
    };
}
