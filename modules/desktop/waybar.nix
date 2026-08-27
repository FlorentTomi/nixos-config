{
  flake.modules.homeManager.waybar =
    {
      osConfig,
      lib,
      pkgs,
      themePalette,
      ...
    }:
    let
      vpnNames = import ../../resources/vpn-names.nix { inherit osConfig; };
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
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        style = ''
          ${builtins.readFile ../../resources/waybar-style.css}

          * {
            font-family: "JetBrainsMono Nerd Font";
            color: #${themePalette.text};
          }

          tooltip {
              background: alpha(#${themePalette.popup.background}, 0.5);
              color: #${themePalette.popup.text};
          }

          .module {
            background-color: #${themePalette.background};
            border-color: #${themePalette.background-alt};
          }

          #custom-power {
            background-color: #${themePalette.image.red};
            color: #${themePalette.dark.text};
            border-color: #${themePalette.image.red};
          }

          #cpu {
            color: #${themePalette.image.orange};
          }

          #temperature {
            color: #${themePalette.image.yellow};
          }

          #custom-gpu {
            color: #${themePalette.image.green};
          }

          #memory {
            color: #${themePalette.image.cyan};
          }

          #disk {
            color: #${themePalette.image.blue};
          }

          #workspaces button label {
              font-family: "JetBrainsMono Nerd Font Mono";
          }

          #workspaces button.focused {
            border-bottom-color: #${themePalette.accent};
          }

          #workspaces button.focused label {
            color: #${themePalette.accent};
          }

          #workspaces button.urgent {
            border-bottom-color: #${themePalette.image.orange};
          }

          #workspaces button.urgent label {
            color: #${themePalette.image.orange};
          }

          #custom-vpn {
            color: #${themePalette.warning};
          }

          #custom-vpn.connected {
            color: #${themePalette.image.green};
          }

          #pulseaudio-slider slider {
            background-color: #${themePalette.background-selection};
          }

          #pulseaudio-slider trough {
            background-color: #${themePalette.popup.progressbar-incomplete};
          }

          #pulseaudio-slider highlight {
            background-color: #${themePalette.popup.progressbar-complete};
          }

          #pulseaudio-slider.muted trough {
            background-color: #${themePalette.popup.progressbar-incomplete};
          }
        '';

        settings.mainBar = {
          layer = "top";
          position = "top";
          exclusive = true;
          margin-top = 8;
          margin-left = 8;
          margin-right = 8;

          modules-left = [
            "custom/power"
            "cpu"
            "temperature"
            "custom/gpu"
            "memory"
            "disk"
            "niri/workspaces"
          ];

          "custom/power" = {
            format = "󰍃";
            tooltip = false;
            on-click = "wleave";
            min-length = 4;
          };

          cpu = {
            interval = 5;
            min-length = 8;
            format = "󰍛 {usage}%";
            on-click = "ghostty --confirm-close-surface=false -e btop";
            align = 0.5;
          };

          temperature = {
            interval = 5;
            min-length = 8;
            critical-threshold = 100;
            format = " {temperatureC}°C";
            # k10temp's PCI device path is fixed to this board; hwmon1's number
            # isn't (probe order can shift it on kernel/driver updates).
            hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
            input-filename = "temp1_input";
            align = 0.5;
          };

          "custom/gpu" = {
            interval = 5;
            min-length = 8;
            format = "󰾲 {}";
            tooltip = false;
            exec = "nvtop -s | jq -r '.[].gpu_util'";
            on-click = "ghostty --confirm-close-surface=false -e nvtop";
            align = 0.5;
          };

          memory = {
            interval = 5;
            min-length = 9;
            format = "  {percentage}%";
            on-click = "ghostty --confirm-close-surface=false -e btop";
            align = 0.5;
          };

          disk = {
            interval = 10;
            format = "󱑛 {percentage_used}% (Free: {free})";
            on-click = "ghostty --confirm-close-surface=false -e diskonaut /home";
            on-click-right = "ghostty --confirm-close-surface=false -e diskonaut /";
          };

          "niri/workspaces" = {
            format = "{icon}";
            hide-empty = true;
            format-icons = {
              active = "󰝤";
              default = "";
              urgent = "󱈸";
              empty = "󰐕";
            };
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
            "group/volume-drawer"
            "tray"
            "clock"
          ];

          tray = {
            spacing = 4;
          };

          "group/volume-drawer" = {
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
            min-length = 8;
            justify = "center";
            format = "{icon} {volume}%";
            format-muted = "";
            format-icons = {
              default = " ";
            };
            on-click = "swayosd-client --output-volume mute-toggle";
            on-click-right = "pavucontrol";
            on-click-middle = "walker -m menus:audio-mixer";
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
            min-length = 5;
            format-icons = {
              connected = "󰌾";
              disconnected = "󰌿";
            };
            on-click = "walker -m menus:vpn";
          };

          "custom/vpn#full" = {
            exec = "${vpnStatus}/bin/waybar-vpn-status";
            return-type = "json";
            interval = 1;
            format = " {} ";
            on-click = "walker -m menus:vpn";
          };

          clock = {
            interval = 60;
            format = " {:%Y/%m/%d  %H:%M}";
            max-length = 25;
            tooltip = false;
          };
        };
      };
    };
}
