{
  config,
  osConfig,
  lib,
  pkgs,
  catppuccinPalette,
  ...
}:

let
  vpnNames = import ./resources/vpn-names.nix { inherit osConfig; };
  vpnSelect = import ./resources/vpn-select.nix { inherit lib pkgs vpnNames; };

  # fuzzel dmenu picker for the waybar VPN drawer — theming now comes from
  # catppuccin.fuzzel.enable (home/ftomi/theme.nix) instead of Stylix,
  # single click accepts by default.
  vpnMenu = pkgs.writeShellApplication {
    name = "waybar-vpn-menu";
    runtimeInputs = [
      config.programs.fuzzel.package
      vpnSelect
    ];
    text = ''
      selected=$(vpn-select | fuzzel --dmenu --prompt "VPN> ")
      [[ -n "$selected" ]] && vpn-select "$selected"
    '';
  };

  vpnStatus = pkgs.writeShellApplication {
    name = "waybar-vpn-status";
    runtimeInputs = [
      pkgs.systemd
      pkgs.jq
    ];
    text = ''
      vpns=(${lib.concatStringsSep " " vpnNames})
      active=()

      for name in "''${vpns[@]}"; do
        systemctl is-active --quiet "openvpn-$name" && active+=("$name")
      done

      if [[ ''${#active[@]} -eq 0 ]]; then
        jq -nc '{text: "No active VPN", alt: "disconnected", class: "disconnected", tooltip: "No VPN active"}'
      else
        tooltip=$(printf '%s\n' "''${active[@]}")
        jq -nc --arg t "''${active[*]}" --arg tt "$tooltip" \
          '{text: $t, alt: "connected", class: "connected", tooltip: $tt}'
      fi
    '';
  };

  # The built-in "mpris" module never hides its own widget when there's no
  # player (confirmed empirically — it just renders an empty label inside a
  # still-visible, still-bordered box), so the #mpris-drawer group pill stays
  # visible even with nothing playing. A "custom" module's box, by contrast,
  # is fully removed by "hide-empty-text" when its script prints no text —
  # so the drawer's chrome moved from the group onto this module (see
  # waybar-style.css) actually disappears.
  mprisStatus = pkgs.writeShellApplication {
    name = "waybar-mpris-status";
    runtimeInputs = [
      pkgs.playerctl
      pkgs.jq
    ];
    text = ''
      mode="$1"

      trunc() {
        local s="$1"
        if [[ ''${#s} -gt 24 ]]; then
          printf '%s…' "''${s:0:24}"
        else
          printf '%s' "$s"
        fi
      }

      esc() {
        local s="$1"
        s="''${s//&/&amp;}"
        s="''${s//</&lt;}"
        s="''${s//>/&gt;}"
        printf '%s' "$s"
      }

      status=$(playerctl status 2>/dev/null || true)
      if [[ -z "$status" || "$status" == "Stopped" ]]; then
        echo '{"text":""}'
        exit 0
      fi
      class=$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')
      player=$(playerctl metadata --format '{{ playerName }}' 2>/dev/null || true)
      artist=$(playerctl metadata artist 2>/dev/null || true)
      title=$(playerctl metadata title 2>/dev/null || true)

      artist_full=$(esc "$artist")
      title_full=$(esc "$title")
      if [[ -n "$artist_full" && -n "$title_full" ]]; then
        dynamic_full="$artist_full - $title_full"
      else
        dynamic_full="$artist_full$title_full"
      fi

      case "$mode" in
        compact)
          icon="▶"
          [[ "$player" == mpv* ]] && icon="🎵"
          text="$icon"
          [[ "$status" == "Paused" ]] && text="⏸"
          ;;
        full)
          artist_t=$(esc "$(trunc "$artist")")
          title_t=$(esc "$(trunc "$title")")
          if [[ -n "$artist_t" && -n "$title_t" ]]; then
            dynamic="$artist_t - $title_t"
          else
            dynamic="$artist_t$title_t"
          fi
          text="$dynamic"
          [[ "$status" == "Paused" ]] && text="<i>$dynamic</i>"
          ;;
      esac

      tooltip="$player ($status) $dynamic_full"
      jq -nc --arg t "$text" --arg c "$class" --arg tt "$tooltip" \
        '{text: $t, class: $c, tooltip: $tt}'
    '';
  };
in
{
  programs.fuzzel.enable = true;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    # Built explicitly here as a single string, rather than relying on
    # catppuccin.waybar.enable's own contribution (lib.mkBefore) and ours
    # (lib.mkAfter) composing correctly across two separate modules into
    # `programs.waybar.style` — see home/ftomi/theme.nix for why. Reading
    # config.catppuccin.sources.waybar directly reproduces exactly what
    # that module would have generated in "prependImport" mode.
    style = lib.mkAfter ''
      ${builtins.readFile ./resources/waybar-style.css}
    '';

    settings.mainBar = {
      layer = "bottom";
      position = "top";
      exclusive = true;

      modules-left = [
        "custom/power"
        "cpu"
        "temperature"
        "custom/gpu"
        "memory"
        "disk"
      ];
      "custom/power" = {
        format = "󰐥";
        tooltip = false;
        on-click = "wleave";
        min-length = 4;
      };
      cpu = {
        interval = 5;
        format = " {usage}%";
        on-click = "ghostty --confirm-close-surface=false -e btop";
      };
      temperature = {
        interval = 5;
        critical-threshold = 100;
        format = " {temperatureC}°C";
        # k10temp's PCI device path is fixed to this board; hwmon1's number
        # isn't (probe order can shift it on kernel/driver updates).
        hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
        input-filename = "temp1_input";
      };
      "custom/gpu" = {
        interval = 5;
        format = "󱓞 {}";
        tooltip = false;
        exec = "nvtop -s | jq -r '.[].gpu_util'";
      };
      memory = {
        interval = 5;
        format = "  {percentage}%";
        on-click = "ghostty --confirm-close-surface=false -e btop";
      };
      disk = {
        interval = 10;
        format = "󰋊 {percentage_used}% (Free: {free})";
        on-click = "ghostty --confirm-close-surface=false -e gdu -x /home";
        on-click-right = "ghostty --confirm-close-surface=false -e gdu -x /";
      };

      modules-center = [ "niri/window" ];
      "niri/window" = {
        separate-outputs = true;
        icon = true;
      };

      modules-right = [
        "group/mpris-drawer"
        "group/vpn-drawer"
        "group/volume"
        "tray"
        "clock"
      ];
      "group/mpris-drawer" = {
        orientation = "inherit";
        drawer = {
          transition-duration = 500;
          children-class = "mpris";
          transition-left-to-right = false;
        };
        modules = [
          "custom/mpris#compact"
          "custom/mpris#full"
        ];
      };
      "custom/mpris#compact" = {
        exec = "${mprisStatus}/bin/waybar-mpris-status compact";
        return-type = "json";
        interval = 1;
        hide-empty-text = true;
        on-click = "playerctl play-pause";
        on-click-middle = "playerctl previous";
        on-click-right = "playerctl next";
      };
      "custom/mpris#full" = {
        exec = "${mprisStatus}/bin/waybar-mpris-status full";
        return-type = "json";
        interval = 1;
        hide-empty-text = true;
        on-click = "playerctl play-pause";
        on-click-middle = "playerctl previous";
        on-click-right = "playerctl next";
      };
      tray = {
        spacing = 4;
      };
      "group/volume" = {
        orientation = "inherit";
        drawer = {
          transition-duration = 500;
          children-class = "volume";
          transition-left-to-right = false;
        };
        modules = [
          "pulseaudio"
          "pulseaudio/slider#out"
        ];
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "";
        format-icons = {
          default = " ";
        };
        on-click = "swayosd-client --output-volume mute-toggle";
        on-click-right = "pavucontrol";
      };
      "pulseaudio/slider#out" = {
        min = 0;
        max = 100;
        orientation = "horizontal";
        zero-on-mute = true;
        unmute-on-volume-change = true;
      };
      "group/vpn-drawer" = {
        orientation = "inherit";
        drawer = {
          transition-duration = 500;
          children-class = "vpn";
          transition-left-to-right = false;
        };
        modules = [
          "custom/vpn#compact"
          "custom/vpn#full"
        ];
      };
      "custom/vpn#compact" = {
        exec = "${vpnStatus}/bin/waybar-vpn-status";
        return-type = "json";
        interval = 1;
        format = "{icon}";
        format-icons = {
          connected = "󰌾";
          disconnected = "󰌿";
        };
        on-click = "${vpnMenu}/bin/waybar-vpn-menu";
      };
      "custom/vpn#full" = {
        exec = "${vpnStatus}/bin/waybar-vpn-status";
        return-type = "json";
        interval = 1;
        format = "{}";
        on-click = "${vpnMenu}/bin/waybar-vpn-menu";
      };
      clock = {
        interval = 60;
        format = " {:%Y/%m/%d  %H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        max-length = 25;
        calendar = {
          mode = "month";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          format = {
            months = "<span color='#${catppuccinPalette.blue}'><b>{}</b></span>";
            days = "<span color='#${catppuccinPalette.text}'><b>{}</b></span>";
            weeks = "<span color='#${catppuccinPalette.teal}'><b>W{}</b></span>";
            weekdays = "<span color='#${catppuccinPalette.yellow}'><b>{}</b></span>";
            today = "<span color='#${catppuccinPalette.red}'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
          on-click-middle = "shift_reset";
        };
      };
    };
  };
}
