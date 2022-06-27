{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    overlays = [
      inputs.neovim-nightly-overlay.overlay
    ];
    pkgs = import nixpkgs {
      config.allowUnfree = true;
      inherit overlays system;
    };
  in {
    nixosConfigurations = {
      omnumnom = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./system/omnumnom/configuration.nix
        ];
      };

      devbox = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./system/devbox/configuration.nix
        ];
      };
    };

    homeConfigurations = {
      tuomo = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home-manager/tuomo.nix
          ./home-manager/modules/home-manager.nix
          ./home-manager/modules/git.nix
          ./home-manager/modules/nvim.nix
        ];
      };
    };
  };
}
