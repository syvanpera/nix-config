{ pkgs, lib, ... }:

{
  programs.i3status-rust = {
    enable = true;
    bars = {
      bottom = {
        blocks = [
          {
             block = "disk_space";
             path = "/";
             alias = "/";
             info_type = "available";
             unit = "GB";
             interval = 60;
             warning = 20.0;
             alert = 10.0;
           }
           {
             block = "memory";
             display_type = "memory";
             format_mem = "{mem_used_percents}";
             format_swap = "{swap_used_percents}";
           }
           {
             block = "cpu";
             interval = 1;
           }
           {
             block = "load";
             interval = 1;
             format = "{1m}";
           }
           {
             block = "time";
             interval = 60;
             format = "%a %d.%m %R";
           }
        ];
        settings = {
          theme =  {
            name = "nord-dark";
          };
        };
        icons = "awesome5";
        theme = "nord-dark";
      };
    };
  };

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    config = rec {
      modifier = "Mod4";

      gaps = {
        inner = 5;
        outer = 0;

        smartGaps = true;
        smartBorders = "on";
      };

      keybindings = lib.mkOptionDefault {
        "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "${modifier}+q" = "kill";
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+Shift+r" = "restart";
        "${modifier}+Shift+e" = "exec xfce4-session-logout";
      };

      bars = [
        rec {
          fonts = {
            names = [ "monospace" "Font Awesome 5 Free" ];
            style = "Regular";
            size = 10.0;
          };
          position = "bottom";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-${position}.toml";
        }
      ];
    };
  };
}
