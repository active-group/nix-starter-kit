{
  description = "A simple nix-starter-kit powered user setup";

  inputs = {
    nix-starter-kit.url = "github:active-group/nix-starter-kit";
  };

  outputs =
    { self, nix-starter-kit }:
    let
      # FIXME: fill in values according to your system and OS settings
      system = "aarch64-darwin";
      settings = {
        username = "sperber";
        userFullName = "Mike Sperber";
        email = "sperber@deinprogramm.de";
      };
    in
    {
      homeConfigurations.${settings.username} =
        nix-starter-kit.lib.make-default-home-manager-config system (import ./home.nix settings);

      # This allows you to do, for instance:
      # nix run ~/.config/home-manager#cowsay -- Hallihallo
      inherit (nix-starter-kit) legacyPackages;
    };
}
