{
  description = "A very basic flake";

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
            pkgs: home-manager: user-settings: home-nix:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = (pkgs.lib.optional pkgs.stdenv.isDarwin mac-app-util.homeManagerModules.default) ++ [
                (home-nix user-settings)
              ];
              extraSpecialArgs = { inherit inputs; };
            };

          make-default-home-manager-config =
            system: user-settings: home-nix:
            self.lib.make-home-manager-config self.legacyPackages.${system} home-manager user-settings home-nix;

          # temporary
          make-emacs = import ./emacs;
          make-git = import ./git;
          controlling = import ./controlling;
        };

        templates.default = {
          path = ./templates/default;
          description = "Bootstrap a new nix-starter-kit-powered home-manager setup";
        };

        nixosModules.git =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          let
            cfg = config.active-group.git;
          in
          {
            options.active-group.git = {
              enable = lib.mkEnableOption "git";
              userName = lib.mkOption {
                type = lib.types.nonEmptyStr;
              };
              userEmail = lib.mkOption {
                type = lib.types.nonEmptyStr;
              };
            };
            config = lib.mkIf cfg.enable {
              programs.git = {
                enable = true;
                userName = cfg.userName;
                userEmail = cfg.userEmail;
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
                  pull.rebase = false;
                };
              };
            };
          };

      };
    };
}
