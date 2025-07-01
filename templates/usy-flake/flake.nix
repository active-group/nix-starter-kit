{
  inputs = {
    nix-starter-kit.url = "github:nixos/nixpkgs?ref=release-25.05";
  };

  outputs =
    let userFullName = "Petra Eisenmann";
        email = "....."; in
        user = "eisenmann";
    {
      homeConfigurations.${user} = nix-starter-kit.lib.make-default-hm-config {
      inherit userFullName email user;
      modules = [ nix-starter-kit.nixosModules.basePackages ./home.nix ];
    };
  };
}
