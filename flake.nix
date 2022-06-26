{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
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
        inherit pkgs;

        modules = [
          ./users/tuomo/home.nix
        ];
      };
    };
  };
}
