{ pkgs, lib, ... }:

{
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultOptions = [ "--height 40%" "--reverse" "--border" ];
  };
}
