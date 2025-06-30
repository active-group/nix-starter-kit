{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, mac-app-util }: {

    lib.make-home-manager-config = pkgs: home-manager: user-settings:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules =
          (pkgs.lib.optional pkgs.stdenv.isDarwin mac-app-util.homeManagerModules.default) ++
          [(import ./home.nix user-settings)];
        extraSpecialArgs = {inherit inputs;};
      };

    lib.make-default-home-manager-config = system: user-settings:
      self.lib.make-home-manager-config
        self.legacyPackages.${system}
        home-manager
        user-settings;
    
    legacyPackages.aarch64-darwin =
      import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };

    # temporary
    lib.make-emacs = import ./emacs;
    lib.make-git = import ./git;
    lib.controlling = import ./controlling;
  };
}
