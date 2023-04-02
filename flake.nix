{
  description = "Tinimini's NixOS/Home Manager shenanigans";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpgs-unstable";

    # home-manager = {
    #   url = "github:nix-community/home-manager/release-22.11";
    #
    #   # We want to use the same set of nixpkgs as our system.
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    mkVM = import ./lib/mkvm.nix;

    # Overlays is the list of overlays we want to apply from flake inputs
    # overlays = [
    #   inputs.neovim-nightly-overlay.overlay
    # ];
    pkgs = import nixpkgs {
      config.allowUnfree = true;
      inherit overlays system;
    };
  in {
    nixosConfigurations.vm-intel = mkVM "vm-intel" rec {
      inherit nixpkgs overlays;
      system = "x86_64-linux";
      user   = "tuomo";
    };

#     nixosConfigurations = {
#       devbox = nixpkgs.lib.nixosSystem {
#         inherit system;
#
#         modules = [
#           ./system/devbox/configuration.nix
#           ./modules/fonts.nix
#           ./users/tuomo.nix
#         ];
#       };
#     };
#
#     homeConfigurations = {
#       tuomo = home-manager.lib.homeManagerConfiguration {
#         inherit pkgs;
#
#         modules = [
#           ./home-manager/tuomo.nix
#           ./home-manager/modules/home-manager.nix
#           ./home-manager/modules/i3.nix
#           ./home-manager/modules/awesome.nix
#           ./home-manager/modules/git.nix
#           ./home-manager/modules/tmux.nix
# #          ./home-manager/modules/nvim.nix
#           ./home-manager/modules/fish.nix
#           ./home-manager/modules/fzf.nix
#           ./home-manager/modules/exa.nix
#           ./home-manager/modules/alacritty.nix
#           ./home-manager/modules/starship.nix
# #          ./home-manager/modules/polybar.nix
#         ];
#       };
#     };
  };
}
