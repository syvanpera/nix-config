{ config, pkgs, lib, ... }:

{
  users.users.tuomo = {
    description = "Tuomo Syvänperä";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "password";
    useDefaultShell = true;
    home = "/home/tuomo";
  };
}
