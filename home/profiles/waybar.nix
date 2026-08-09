{
  osConfig,
  lib,
  pkgs,
  catppuccinPalette,
  ...
}:

let
  vpnNames = import ./resources/vpn-names.nix { inherit osConfig; };
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
in
{
  programs.fuzzel.enable = true;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
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
        align = 0.5;
      };
      temperature = {
        interval = 5;
        critical-threshold = 100;
        format = " {temperatureC}°C";
        # k10temp's PCI device path is fixed to this board; hwmon1's number
        # isn't (probe order can shift it on kernel/driver updates).
        hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
        input-filename = "temp1_input";
        align = 0.5;
      };
      "custom/gpu" = {
        interval = 5;
        format = "󱓞 {}";
        tooltip = false;
        exec = "nvtop -s | jq -r '.[].gpu_util'";
        align = 0.5;
      };
      memory = {
        interval = 5;
        format = "  {percentage}%";
        on-click = "ghostty --confirm-close-surface=false -e btop";
        align = 0.5;
      };
      disk = {
        interval = 10;
        format = "󰋊 {percentage_used}% (Free: {free})";
        on-click = "ghostty --confirm-close-surface=false -e diskonaut /home";
        on-click-right = "ghostty --confirm-close-surface=false -e diskonaut /";
      };

      modules-center = [ "niri/window" ];
      "niri/window" = {
        separate-outputs = true;
        icon = true;
        format = "{}";
        rewrite = {
          "(.*) — Ablaze Floorp" = "$1";
        };
      };

      modules-right = [
        "group/vpn-drawer"
        "group/volume"
        "tray"
        "clock"
      ];
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
        on-click = "rofi -show vpn";
      };
      "custom/vpn#full" = {
        exec = "${vpnStatus}/bin/waybar-vpn-status";
        return-type = "json";
        interval = 1;
        format = "{}";
        on-click = "rofi -show vpn";
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
