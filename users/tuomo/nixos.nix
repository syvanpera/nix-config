{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  users.users.tuomo = {
    description = "Tuomo Syvänperä";
    isNormalUser = true;
    home = "/home/tuomo";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    initialPassword = "tuomo";
  };
}
