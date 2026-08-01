# Genuinely core niri: window/workspace management, layout, hardware-level
# media/screenshot keys. No app-launch binds here — those live with the
# capability that provides the app (see e.g. profiles/launcher.nix,
# profiles/lock.nix, profiles/shell.nix) so a host that imports only
# niri-core gets a working (if sparse) WM with no dangling spawn targets.
{ pkgs, osConfig, lib, ... }:

{
  programs.niri = {
    package = pkgs.niri;
    settings = {
      input = {
        # Also set in profiles/ftomi/locale.nix (xserver layer, e.g. greeter/TTY).
        # Niri has its own input stack and doesn't inherit that, so it's repeated here.
        keyboard = {
          numlock = true;
          xkb.layout = "fr";
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

        border.width = 1.;
      };

      hotkey-overlay = {
        skip-at-startup = true;
      };

      # NVIDIA-specific Wayland/DRM env vars — only relevant if this host
      # actually has the nvidia module enabled, so a laptop with a
      # different/no discrete GPU doesn't inherit them.
      environment = lib.mkIf osConfig.modules.nvidia.enable {
        LIBVA_DRIVER_NAME = "nvidia";
        XDG_SESSION_TYPE = "wayland";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct";
        MOZ_DISABLE_RDD_SANDBOX = "1";
      };

      binds = {
        "Mod+F1".action.show-hotkey-overlay = { };

        "Mod+D".action.spawn = [
          "ghostty"
          "--confirm-close-surface=false"
          "-e"
          "nirimon"
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
        "Mod+Ctrl+F".action.fullscreen-window = { };
        "Mod+C".action.center-column = { };
        "Mod+Ctrl+C".action.center-visible-columns = { };

        "Mod+V".action.toggle-window-floating = { };
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

        "Mod+Shift+W".action.toggle-column-tabbed-display = { };

        "Mod+O" = {
          action.toggle-overview = { };
          repeat = false;
        };

        "Mod+Q" = {
          action.close-window = { };
          repeat = false;
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

      prefer-no-csd = true;
      animations.enable = true;
      gestures.hot-corners.enable = false;
    };
  };

  home.packages = [
    pkgs.xwayland-satellite
    pkgs.nirimon
  ];
}
