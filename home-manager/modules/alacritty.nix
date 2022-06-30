{ pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      shell = {
        program = "${pkgs.fish}/bin/fish";
      };
    };
  };
}
