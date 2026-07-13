{ pkgs, ... }:

{
  imports = [
    ./desktop-environment/niri.nix
    ./desktop-environment/shell.nix
    ./desktop-environment/waybar.nix
    ./desktop-environment/yazi.nix
  ];

  programs.fuzzel.enable = true;

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
        {
          label = "lock";
          action = "hyprlock";
          text = "Lock";
          keybind = "l";
          icon = "${pkgs.wleave}/share/wleave/icons/lock.svg";
        }
      ];
    };
  };

  home.packages = [
    pkgs.waypaper
    pkgs.pamixer
    pkgs.pavucontrol
    pkgs.playerctl
  ];

  services = {
    polkit-gnome.enable = true;
    network-manager-applet.enable = true;
    swayidle.enable = true;
    mako.enable = true;
    swayosd.enable = true;
    awww.enable = true;
    playerctld.enable = true;
    wl-clip-persist = {
      enable = true;
      clipboardType = "both";
    };
  };
}
