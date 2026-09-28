{
  description = "A simple nix-starter-kit powered user setup";

  inputs = {
    nix-starter-kit.url = "github:active-group/nix-starter-kit";
  };

  outputs =
    { self, nix-starter-kit }:
    {
      # FIXME: Choose one of the following default configuration based on your
      # system (`sperber` for macOS on Apple Silicone, `maier` for Linux on
      # Intel), delete the other. Afterwards, change the username to your own
      # one in both the curly braces and in homeConfigurations.<username>.
      homeConfigurations.sperber = nix-starter-kit.lib.make-default-home-manager-config "aarch64-darwin" (
        import ./home.nix {
          username = "sperber";
          userFullName = "Mike Sperber";
          email = "sperber@deinprogramm.de";
        }
      );

      homeConfigurations.maier = nix-starter-kit.lib.make-default-home-manager-config "x86_64-linux" (
        import ./home.nix {
          username = "maier";
          userFullName = "Johannes Maier";
          email = "johannes.maier@active-group.de";
        }
      );

      # This allows you to do, for instance:
      # nix run ~/.config/home-manager#cowsay -- Hallihallo
      inherit (nix-starter-kit) legacyPackages;
    };
}
