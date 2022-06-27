{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "tuomo";
  home.homeDirectory = "/home/tuomo";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    firefox
    alacritty
    kitty
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName  = "Tuomo Syvänperä";
    userEmail = "tuomo.syvanpera@gmail.com";
    aliases = {
      st = "status";
      co = "checkout";
    };
  };
}
