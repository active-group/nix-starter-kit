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
    active-accounting.url = "git+ssh://git@gitlab.active-group.de:1022/ag/active-accounting.git";
    active-timetracking.url = "git+ssh://git@gitlab.active-group.de:1022/ag/active-timetracking.git";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { config, system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          legacyPackages = pkgs;

          packages.update-daemon = pkgs.callPackage ./packages/update-daemon.nix { };
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

        nixosModules =
          let
            # NOTE(Johannes):
            # 1.  In order for consumers of these modules to use the inputs of this flake, we need to in
            #     effect close over our inputs.
            # 2.  We then need to match on `pkgs`, as without this explicit match the evaluator will just
            #     not inject them.
            withInputs = modulePath: args@{ pkgs, ... }: import modulePath (args // { inherit inputs; });
          in
          {
            default = {
              imports = [
                self.nixosModules.git
                self.nixosModules.nix-starter-kit
                self.nixosModules.mac-app-util
                self.nixosModules.emacs
                self.nixosModules.controlling
                self.nixosModules.zsh
                self.nixosModules.timetracking
              ];
            };
            git = withInputs ./modules/git;
            nix-starter-kit = withInputs ./modules/nix-starter-kit.nix;
            mac-app-util = withInputs ./modules/mac-app-util;
            emacs = withInputs ./modules/emacs;
            controlling = withInputs ./modules/controlling;
            zsh = withInputs ./modules/zsh;
            timetracking = withInputs ./modules/timetracking;
          };
      };
    };
}
