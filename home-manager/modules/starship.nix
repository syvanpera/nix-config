{ pkgs, lib, ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      username = {
        format = "[╭─$user]($style)@";
        style_user = "bold red";
        style_root = "bold red";
        show_always = true;
      };

      hostname = {
        format = "[$hostname]($style) in ";
        style = "bold dimmed red";
        trim_at = "-";
        ssh_only = false;
        disabled = false;
      };

      directory = {
        style = "purple";
        truncation_length = 0;
        truncate_to_repo = true;
        truncation_symbol = "repo: ";
      };

      cmd_duration = {
        min_time = 1;
        format = "took [$duration]($style)";
        disabled = false;
      };

      character = {
        success_symbol = "[╰─λ](bold red)";
        error_symbol = "[×](bold red)";
      };

      git_branch = {
        symbol = " ";
      };

      golang = {
        symbol = " ";
      };
    };
  };
}
