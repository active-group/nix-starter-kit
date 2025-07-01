{
  description = "A simple nix-starter-kit powered user setup";

  inputs = {
    nix-starter-kit.url = "path:/home/void/ag/nix-starter-kit";
  };

  outputs =
    { self, nix-starter-kit }:
    let
      # FIXME
      system = "x86_64-linux";
      settings = {
        username = "sperber";
        userFullName = "Mike Sperber";
        email = "sperber@deinprogramm.de";
      };
    in
    {
      homeConfigurations.${settings.username} =
        nix-starter-kit.lib.make-default-home-manager-config system (import ./home.nix settings);
    };
}
