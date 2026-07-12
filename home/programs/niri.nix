{ pkgs, ... }:

{
  programs.niri.package = pkgs.niri;
  programs.niri.settings = {
    input = {
      keyboard = {
        numlock = true;
        xkb.layout = "fr";
      };
    };

    outputs = {
      "DP-1" = {
        mode = {
          width = 3840;
          height = 2160;
          refresh = 59.997;
        };
        scale = 1.0;
        position = {
          x = 0;
          y = 0;
        };
        focus-at-startup = true;
      };
      "HDMI-A-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 144.001;
        };
        scale = 1.0;
        position = {
          x = 3840;
          y = 0;
        };
        focus-at-startup = false;
      };
    };

    spawn-at-startup = [
      {
        argv = [
          "waypaper"
          "--restore"
        ];
      }
    ];

    layout = {
      gaps = 0;
      always-center-single-column = false;
      preset-column-widths = [
        { proportion = 1. / 3.; }
        { proportion = 1. / 2.; }
        { proportion = 2. / 3.; }
        { proportion = 1.; }
      ];
      default-column-width = {
        proportion = 1. / 2.;
      };

      preset-window-heights = [
        { proportion = 1. / 3.; }
        { proportion = 1. / 2.; }
        { proportion = 2. / 3.; }
        { proportion = 1.; }
      ];

      border.enable = false;
    };

    hotkey-overlay = {
      skip-at-startup = true;
    };

    environment = {
      LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
      MOZ_DISABLE_RDD_SANDBOX = "1";
    };

    binds = {
      "Mod+F1".action.show-hotkey-overlay = { };
      "Mod+Return".action.spawn = "ghostty";
      "Mod+Space".action.spawn = "fuzzel";
      "Mod+B".action.spawn = "floorp";
      "Mod+Z".action.spawn = "zeditor";
      "Mod+L".action.spawn = "hyprlock";

      "Mod+E".action.spawn = [
        "ghostty"
        "--confirm-close-surface=false"
        "-e"
        "yazi"
      ];

      "Mod+P".action.spawn = [
        "ghostty"
        "--confirm-close-surface=false"
        "-e"
        "btop"
      ];

      "Mod+WheelScrollDown".action.focus-workspace-down = { };
      "Mod+WheelScrollUp".action.focus-workspace-up = { };
      "Mod+Shift+WheelScrollDown".action.focus-column-right = { };
      "Mod+Shift+WheelScrollUp".action.focus-column-left = { };
      "Mod+Left".action.focus-column-left = { };
      "Mod+Right".action.focus-column-right = { };
      "Mod+Home".action.focus-column-first = { };
      "Mod+End".action.focus-column-last = { };
      "Mod+Shift+Left".action.focus-monitor-left = { };
      "Mod+Shift+Down".action.focus-monitor-down = { };
      "Mod+Shift+Up".action.focus-monitor-up = { };
      "Mod+Shift+Right".action.focus-monitor-right = { };
      "Mod+Down".action.focus-workspace-down = { };
      "Mod+Up".action.focus-workspace-up = { };
      "Mod+U".action.focus-workspace-down = { };
      "Mod+I".action.focus-workspace-up = { };

      "Mod+Ctrl+WheelScrollDown".action.move-column-to-workspace-down = { };
      "Mod+Ctrl+WheelScrollUp".action.move-column-to-workspace-up = { };
      "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = { };
      "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = { };
      "Mod+Ctrl+Left".action.move-column-left = { };
      "Mod+Ctrl+Right".action.move-column-right = { };
      "Mod+Ctrl+Home".action.move-column-to-first = { };
      "Mod+Ctrl+End".action.move-column-to-last = { };
      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = { };
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = { };
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = { };
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = { };
      "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = { };
      "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = { };
      "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = { };
      "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = { };
      "Mod+Ctrl+Down".action.move-column-to-workspace-down = { };
      "Mod+Ctrl+Up".action.move-column-to-workspace-up = { };
      "Mod+Shift+Page_Down".action.move-workspace-down = { };
      "Mod+Shift+Page_Up".action.move-workspace-up = { };
      "Mod+Shift+U".action.move-workspace-down = { };
      "Mod+Shift+I".action.move-workspace-up = { };

      "Mod+R".action.switch-preset-column-width = { };
      "Mod+Shift+R".action.switch-preset-column-width-back = { };
      "Mod+Ctrl+Shift+R".action.switch-preset-window-height = { };
      "Mod+Ctrl+R".action.reset-window-height = { };

      "Mod+F".action.maximize-column = { };
      "Mod+Shift+F".action.fullscreen-window = { };
      # "Mod+M".action.maximize-window-to-edges = { };
      "Mod+Ctrl+F".action.expand-column-to-available-width = { };
      "Mod+C".action.center-column = { };
      "Mod+Ctrl+C".action.center-visible-columns = { };

      "Mod+V".action.toggle-window-floating = { };
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

      "Mod+Shift+W".action.toggle-column-tabbed-display = { };

      "Mod+O" = {
        action.toggle-overview = {  };
        repeat=false;
      };

      "Mod+Q" = {
        action.close-window = {};
        repeat=false;
      };

      "XF86AudioRaiseVolume".action.spawn = [
        "swayosd-client"
        "--output-volume"
        "raise"
      ];

      "XF86AudioLowerVolume".action.spawn = [
        "swayosd-client"
        "--output-volume"
        "lower"
      ];

      "XF86AudioMute".action.spawn = [
        "swayosd-client"
        "--output-volume"
        "mute-toggle"
      ];

      "XF86AudioMicMute".action.spawn = [
        "swayosd-client"
        "--input-volume"
        "mute-toggle"
      ];

      "XF86AudioPlay".action.spawn = [
        "swayosd-client"
        "--playerctl"
        "play-pause"
      ];

      "XF86AudioStop".action.spawn = [
        "swayosd-client"
        "--playerctl"
        "stop"
      ];

      "XF86AudioPrev".action.spawn = [
        "swayosd-client"
        "--playerctl"
        "prev"
      ];

      "XF86AudioNext".action.spawn = [
        "swayosd-client"
        "--playerctl"
        "next"
      ];

      "Print".action.screenshot = { };
      "Ctrl+Print".action.screenshot-screen = { };
      "Alt+Print".action.screenshot-window = { };

      "Ctrl+Alt+Delete".action.quit = { };
    };

    window-rules = [
      {
        matches = [
          {
            app-id = "floorp$";
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;
      }
      {
        matches = [
          { app-id = "^steam_app_.*$"; }
        ];
        open-maximized = true;
      }
    ];

    prefer-no-csd = true;
    animations.enable = true;
    gestures.hot-corners.enable = false;
  };
}
