{ pkgs, ... }:

{
  programs.fuzzel.enable = true;
  programs.btop.enable = true;
  programs.bat.enable = true;
  programs.zed-editor.enable = true;
  programs.neovim.enable = true;
  programs.git.enable = true;
  programs.gh.enable = true;
  programs.discord.enable = true;

  programs.ghostty = {
    enable = true;
    settings.background-opacity = 0.9;
  };

  programs.wleave = {
    enable = true;
    settings = {
      buttons = [
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
          icon = "${pkgs.wleave}/share/wleave/icons/shutdown.svg";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
          icon = "${pkgs.wleave}/share/wleave/icons/reboot.svg";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    extraConfig = ''
      $font = JetBrainsMono Nerd Font

      general {
          hide_cursor = false
      }

      animations {
          enabled = true
          bezier = linear, 1, 1, 0, 0
          animation = fadeIn, 1, 5, linear
          animation = fadeOut, 1, 5, linear
          animation = inputFieldDots, 1, 2, linear
      }

      background {
          monitor =
          path = screenshot
          blur_passes = 3
      }

      input-field {
          monitor =
          size = 20%, 5%
          outline_thickness = 3
          inner_color = rgba(0, 0, 0, 0.0) # no fill

          outer_color = rgba(33ccffee) rgba(00ff99ee) 45deg
          check_color = rgba(00ff99ee) rgba(ff6633ee) 120deg
          fail_color = rgba(ff6633ee) rgba(ff0066ee) 40deg

          font_color = rgb(143, 143, 143)
          fade_on_empty = false
          rounding = 15

          font_family = $font
          placeholder_text = Input password...
          fail_text = $PAMFAIL$FPRINTFAIL

          dots_spacing = 0.3

          position = 0, -20
          halign = center
          valign = center
      }

      label {
          monitor =
          text = $TIME
          font_size = 90
          font_family = $font

          position = -30, 0
          halign = right
          valign = top
      }

      label {
          monitor =
          text = cmd[update:60000] date +"%A, %d %B %Y" # update every 60 seconds
          font_size = 25
          font_family = $font

          position = -30, -150
          halign = right
          valign = top
      }

      label {
          monitor =
          text = $LAYOUT
          font_size = 24

          position = 30, -15
          halign = left
          valign = top
      }
    '';
  };

  home.packages = [
    pkgs.tailscale
    pkgs.scrcpy
    pkgs.android-tools
    pkgs.waypaper
    pkgs.floorp-bin
    pkgs.nil
    pkgs.nixd
    pkgs.pamixer
    pkgs.pavucontrol
    pkgs.xwayland-satellite
    pkgs.playerctl
  ];
}
