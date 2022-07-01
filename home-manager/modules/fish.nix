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

    interactiveShellInit = ''
      set -Ua fish_user_paths ~/.local/bin

      set -g theme_nerd_fonts yes
    '';
  };
}
