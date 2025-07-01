{
  description = "Modules and utilities for getting started with home-manager at Active Group";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      flake-parts,
      mac-app-util,
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        { config, system, ... }:
        {
          legacyPackages = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        };
      flake = {
        lib = {
          make-home-manager-config =
            pkgs: home-manager: home-nix:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                self.nixosModules.default
                home-nix
              ];
              extraSpecialArgs = { inherit inputs; };
            };

          make-default-home-manager-config =
            system: home-nix:
            self.lib.make-home-manager-config self.legacyPackages.${system} home-manager home-nix;
        };

        templates.default = {
          path = ./templates/default;
          description = "Bootstrap a new nix-starter-kit-powered home-manager setup";
        };

        nixosModules = {
          default = {
            imports = [
              self.nixosModules.git
              self.nixosModules.nix-starter-kit
              self.nixosModules.mac-app-util
              self.nixosModules.emacs
              self.nixosModules.controlling
            ];
          };
          git = import ./modules/git;
          nix-starter-kit = import ./modules/nix-starter-kit.nix;
          mac-app-util = import ./modules/mac-app-util;
          emacs = import ./modules/emacs;
          controlling = import ./modules/controlling;
        };
      };
    };
}
