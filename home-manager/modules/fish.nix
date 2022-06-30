{ pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      l = "ls -l";
      vi = "nvim";
    };
  };
}
