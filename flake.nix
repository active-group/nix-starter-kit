{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    home-manager,
    flake-utils,
    ...
  }: let
    username = "<USERNAME>";
  in
    flake-utils.lib.eachDefaultSystem (system: {formatter = nixpkgs.legacyPackages.${system}.alejandra;})
    // {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          # Change to your system architecture here, for instance to
          # x86_64-linux, or aarch64-darwin
          system = "x86_64-darwin";
          config.allowUnfree = true;
        };
        modules = [(import ./home.nix username)];
      };
    };
}
