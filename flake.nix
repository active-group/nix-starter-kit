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

  outputs = inputs@{
    nixpkgs,
    home-manager,
    flake-utils,
    ...
  }: let
    username = "<USERNAME>";
    # Change to your system architecture here; common values are
    # "x86_64-darwin", "aarch64-darwin", or "x86_64-linux"
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [(import ./home.nix username)];
      extraSpecialArgs = {inherit inputs;};
    };
    formatter.${system} = pkgs.alejandra;
  };
}
