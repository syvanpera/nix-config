{ pkgs, ... }:

{
  home.username = "tuomo";
  home.homeDirectory ="/home/tuomo";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    fd
    tig
    bat
    procs
    neovim-nightly
    ripgrep
    firefox
  ];

  xdg.configFile.nvim = {
    source = ./dotfiles/config/nvim;
    recursive = true;
  };

  # Dotfiles
  #home.file.".config/nvim".source = ./dotfiles/config/nvim;
  home.file.".local/bin".source = ./dotfiles/local/bin;
  home.file.".tmux.conf".source = ./dotfiles/tmux.conf;
  home.file.".tmux".source = ./dotfiles/tmux;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";
}
