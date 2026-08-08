# Genuinely core niri: window/workspace management, layout, hardware-level
# media/screenshot keys. No app-launch binds here — those live with the
# capability that provides the app (see e.g. profiles/launcher.nix,
# profiles/lock.nix, profiles/shell.nix) so a host that imports only
# niri-core gets a working (if sparse) WM with no dangling spawn targets.
{ config, pkgs, osConfig, lib, catppuccinPalette, ... }:

{
  # modules/niri.nix (NixOS-level) still imports niri-flake's nixosModules.niri
  # for systemd/portal/polkit wiring. That module unconditionally injects its
  # own homeModules.config into home-manager.sharedModules whenever
  # home-manager is present at all — regardless of whether we ever touch
  # programs.niri ourselves — which writes its own niri/config.kdl in
  # parallel with wayland.windowManager.niri below. Same target file, two
  # writers, hence the "Conflicting managed target files" assertion.
  # Disabling niri-flake's entry by its xdg.configFile key (not the target
  # path) leaves ours as the only writer.
  xdg.configFile.niri-config.enable = lib.mkForce false;

  wayland.windowManager.niri = {
    enable = true;
    package = pkgs.niri;

    # modules/niri.nix (NixOS-level, via niri-flake) already installs niri's
    # systemd units and configures xdg-portal system-wide. Disable this
    # module's own copies of both so we don't end up with two sources of
    # truth for the same thing.
    systemd.enable = false;
    portalPackage = null;
    # xwayland-satellite is already declared explicitly below in
    # home.packages, so don't let this module add a second copy.
    xwaylandSatellitePackage = null;
    settings = {
      input = {
        keyboard = {
          # best-effort: numlock is a flag in niri's KDL grammar (no
          # argument), not a bool-valued node. Verify with `niri validate`.
          numlock = { };
          # Single source of truth: profiles/ftomi/locale.nix sets
          # services.xserver.xkb.layout; read it back instead of duplicating
          # the layout string here.
          xkb.layout = osConfig.services.xserver.xkb.layout;
        };
      };

      # spawn-at-startup takes its command as positional node arguments
      # (`spawn-at-startup "cmd" "arg"`), not a named `argv` property.
      spawn-at-startup._args = [
        "waypaper"
        "--restore"
      ];

      layout = {
        gaps = 0;
        # best-effort: also a flag node. `false` is niri's default, so
        # omitting it entirely has the same effect — leaving this comment
        # instead of the line so the intent isn't lost.
        # always-center-single-column = false;
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

        # This is the actual fix for the active border extending past
        # screen edges: with gaps = 0 above, niri's *default* focus-ring
        # (drawn outside each window, in the gap) has no gap to render
        # into at screen edges, so it bleeds past the visible area.
        # niri-flake's Stylix module used to disable focus-ring and switch
        # to `border` instead, which is drawn as part of the window's own
        # space and doesn't need a gap to render correctly. Both nest
        # under `layout`, not top-level.
        focus-ring.off = { };
        border = {
          active-color = "#${catppuccinPalette.blue}";
          inactive-color = "#${catppuccinPalette.overlay0}";
        };
      };

      hotkey-overlay = {
        # best-effort: flag node.
        skip-at-startup = { };
      };

      # cursor IS top-level (unlike focus-ring/border above, which nest
      # under layout) — matches niri's actual node hierarchy.
      cursor = {
        # niri's actual KDL node names are xcursor-theme / xcursor-size —
        # niri-flake's typed schema called these `theme`/`size` internally
        # and translated them under the hood; the freeform module doesn't,
        # so the raw KDL names have to be used directly here. Sourced from
        # home.pointerCursor (theme.nix) rather than Stylix now.
        xcursor-theme = config.home.pointerCursor.name;
        xcursor-size = config.home.pointerCursor.size;
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
        "Ctrl+Print".screenshot-screen = { };
        "Alt+Print".screenshot-window = { };

        "Ctrl+Alt+Delete".quit = { };
      };

      # best-effort: prefer-no-csd is a top-level flag node.
      prefer-no-csd = { };
      # best-effort: animations are enabled by default; an empty block just
      # documents intent without changing behavior.
      animations = { };
      # best-effort: `off` is niri's flag for disabling hot-corners.
      gestures.hot-corners.off = { };
    };
  };

  home.packages = [
    pkgs.xwayland-satellite
    pkgs.nirimon
  ];
}
