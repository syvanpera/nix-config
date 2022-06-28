{ pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    font-awesome_5
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  ];
}
