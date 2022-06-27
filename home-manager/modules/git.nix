{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName  = "Tuomo Syvänperä";
    userEmail = "tuomo.syvanpera@gmail.com";

    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
      };
    };

    aliases = {
      st = "status";
      co = "checkout";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
    };

    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
      github.user = "syvanpera";

      core = {
        editor = "nvim";
      };
    };
  };
}
