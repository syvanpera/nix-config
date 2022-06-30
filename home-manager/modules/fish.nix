{ pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "${pkgs.exa}/bin/exa";
      l = "ls -l";
      vi = "nvim";
      cat = "bat";
    };
  };
}
