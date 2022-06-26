{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;

      config = { allowUnfree = true; };
    };
  in {
    nixosConfigurations = {
      omnumnom = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./system/omnumnom/configuration.nix
        ];
      };
    };

    homeConfigurations = {
      tuomo = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        modules = [
          ./users/tuomo/home.nix
        ];
      };
    };
  };
}
