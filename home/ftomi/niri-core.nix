{
  config,
  pkgs,
  osConfig,
  lib,
  catppuccinPalette,
  ...
}:

{
  xdg.configFile.niri-config.enable = lib.mkForce false;

  wayland.windowManager.niri = {
    enable = true;
    package = pkgs.niri;
    systemd.enable = false;
    portalPackage = null;

    xwaylandSatellitePackage = null;
    settings = {
      input = {
        keyboard = {
          numlock = { };
          xkb.layout = osConfig.services.xserver.xkb.layout;
        };
      };

      _children = [
        {
          spawn-at-startup._args = [
            "waypaper"
            "--restore"
          ];
        }
        {
          spawn-at-startup._args = [ "pasystray" ];
        }
      ];

      layout = {
        gaps = 0;

        preset-column-widths._children = [
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
          { proportion = 1.; }
        ];

        default-column-width = {
          proportion = 1. / 2.;
        };

        preset-window-heights._children = [
          { proportion = 1. / 3.; }
          { proportion = 1. / 2.; }
          { proportion = 2. / 3.; }
          { proportion = 1.; }
        ];

        focus-ring.off = { };

        border = {
          active-color = "#${catppuccinPalette.blue}";
          inactive-color = "#${catppuccinPalette.overlay0}";
        };
      };

      hotkey-overlay = {
        skip-at-startup = { };
      };

      cursor = {
        xcursor-theme = config.home.pointerCursor.name;
        xcursor-size = config.home.pointerCursor.size;
      };

      environment = lib.mkIf osConfig.modules.nvidia.enable {
        LIBVA_DRIVER_NAME = "nvidia";
        XDG_SESSION_TYPE = "wayland";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct";
        MOZ_DISABLE_RDD_SANDBOX = "1";
      };

      binds = {
        "Mod+F1".show-hotkey-overlay = { };

        "Mod+P".spawn = [
          "ghostty"
          "--confirm-close-surface=false"
          "-e"
          "nirimon"
        ];

        "Mod+WheelScrollDown".focus-workspace-down = { };
        "Mod+WheelScrollUp".focus-workspace-up = { };
        "Mod+Shift+WheelScrollDown".focus-column-right = { };
        "Mod+Shift+WheelScrollUp".focus-column-left = { };
        "Mod+Left".focus-column-left = { };
        "Mod+Right".focus-column-right = { };
        "Mod+Home".focus-column-first = { };
        "Mod+End".focus-column-last = { };
        "Mod+Shift+Left".focus-monitor-left = { };
        "Mod+Shift+Down".focus-monitor-down = { };
        "Mod+Shift+Up".focus-monitor-up = { };
        "Mod+Shift+Right".focus-monitor-right = { };
        "Mod+Down".focus-workspace-down = { };
        "Mod+Up".focus-workspace-up = { };
        "Mod+U".focus-workspace-down = { };
        "Mod+I".focus-workspace-up = { };

        "Mod+Ctrl+WheelScrollDown".move-column-to-workspace-down = { };
        "Mod+Ctrl+WheelScrollUp".move-column-to-workspace-up = { };
        "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = { };
        "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = { };
        "Mod+Ctrl+Left".move-column-left = { };
        "Mod+Ctrl+Right".move-column-right = { };
        "Mod+Ctrl+Home".move-column-to-first = { };
        "Mod+Ctrl+End".move-column-to-last = { };
        "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = { };
        "Mod+Shift+Ctrl+H".move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+J".move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+K".move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+L".move-column-to-monitor-right = { };
        "Mod+Ctrl+Down".move-column-to-workspace-down = { };
        "Mod+Ctrl+Up".move-column-to-workspace-up = { };
        "Mod+Shift+Page_Down".move-workspace-down = { };
        "Mod+Shift+Page_Up".move-workspace-up = { };
        "Mod+Shift+U".move-workspace-down = { };
        "Mod+Shift+I".move-workspace-up = { };

        "Mod+R".switch-preset-column-width = { };
        "Mod+Shift+R".switch-preset-column-width-back = { };
        "Mod+Ctrl+Shift+R".switch-preset-window-height = { };
        "Mod+Ctrl+R".reset-window-height = { };

        "Mod+F".maximize-column = { };
        "Mod+Ctrl+F".fullscreen-window = { };
        "Mod+C".center-column = { };
        "Mod+Ctrl+C".center-visible-columns = { };

        "Mod+V".toggle-window-floating = { };
        "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };

        "Mod+Shift+W".toggle-column-tabbed-display = { };

        "Mod+O" = {
          _props.repeat = false;
          toggle-overview = { };
        };

        "Mod+Q" = {
          _props.repeat = false;
          close-window = { };
        };

        "XF86AudioRaiseVolume".spawn = [
          "swayosd-client"
          "--output-volume"
          "raise"
        ];

        "XF86AudioLowerVolume".spawn = [
          "swayosd-client"
          "--output-volume"
          "lower"
        ];

        "XF86AudioMute".spawn = [
          "swayosd-client"
          "--output-volume"
          "mute-toggle"
        ];

        "XF86AudioMicMute".spawn = [
          "swayosd-client"
          "--input-volume"
          "mute-toggle"
        ];

        "XF86AudioPlay".spawn = [
          "swayosd-client"
          "--playerctl"
          "play-pause"
        ];

        "XF86AudioStop".spawn = [
          "swayosd-client"
          "--playerctl"
          "stop"
        ];

        "XF86AudioPrev".spawn = [
          "swayosd-client"
          "--playerctl"
          "prev"
        ];

        "XF86AudioNext".spawn = [
          "swayosd-client"
          "--playerctl"
          "next"
        ];

        "Print".screenshot = { };
        "Ctrl+Print".screenshot-screen = {
          _props.write-to-disk = false;
        };
        "Alt+Print".screenshot-window = {
          _props.write-to-disk = false;
        };

        "Ctrl+Alt+Delete".quit = { };
      };

      prefer-no-csd = { };
      animations = { };
      gestures.hot-corners.off = { };
    };
  };

  home.packages = [
    pkgs.xwayland-satellite
    pkgs.nirimon
  ];
}
