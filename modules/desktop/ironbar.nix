{
  flake.modules.homeManager.ironbar =
    { inputs, themePalette, ... }:
    let
      bar-name = "main";
      font-size = 12;
      icon-size = 16;
    in
    {
      imports = [ inputs.ironbar.homeManagerModules.default ];

      nix.settings = {
        extra-substituters = [ "https://jakestanger.cachix.org" ];
        extra-trusted-public-keys = [
          "jakestanger.cachix.org-1:VWJE7AWNe5/KOEvCQRxoE8UsI2Xs2nHULJ7TEjYm7mM="
        ];
      };

      programs.ironbar = {
        enable = true;
        systemd = true;
        config = {
          name = bar-name;
          anchor_to_edges = true;
          popup_autohide = true;
          height = 20;
          position = "top";
          margin.top = 4;
          margin.left = 4;
          margin.right = 4;
          icon_theme = "Papirus-Dark";
          double_click_time = "gtk";

          start = [
            {
              type = "custom";
              name = "power-container";
              bar = [
                {
                  type = "button";
                  name = "power-btn";
                  label = "󰍃";
                  on_click = "!wleave";
                }
              ];
            }
            {
              type = "custom";
              name = "sysinfo";
              bar = [
                {
                  type = "sys_info";
                  name = "cpu";
                  format = [ " {cpu_percent}%" ];
                }
                {
                  type = "sys_info";
                  name = "temperature";
                  format = [ " {temp_c@k10temp Tctl}°C" ];
                }
                {
                  type = "sys_info";
                  name = "memory";
                  format = [ "  {memory_percent}%" ];
                }
                {
                  type = "sys_info";
                  name = "disk";
                  format = [ "󰋊 {disk_percent@/}% (Free: {disk_free@/#G}GB)" ];
                }
              ];
            }
            {
              type = "workspaces";
              format = "{index}";
            }
          ];

          center = [
            {
              type = "focused";
              name = "current-window";
              icon_size = icon-size;
              transition_type = "none";
              truncate = {
                mode = "end";
                max_length = 40;
              };
              show_if = {
                mode = "poll";
                interval = 100;
                cmd = "niri msg -j focused-window | jq -e '.title != null and .title != \"\"'";
              };
            }
          ];

          end = [
            {
              type = "volume";
              show_sinks = true;
              show_sources = false;
            }
            {
              type = "volume";
              show_sinks = false;
              show_sources = true;
            }
            {
              type = "tray";
              icon_size = icon-size;
            }
            {
              type = "clock";
              format = " %Y/%m/%d  %H:%M";
              format_popup = "%H:%M";
            }
            {
              type = "notifications";
            }
          ];
        };

        style = ''
          :root {
            --spacing: 4px;
          }

          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: ${toString font-size}px;
            font-weight: bold;
            border-radius: 0;
            box-shadow: none;
            min-height: 0;
            min-width: 0;
          }

          .background {
            background: transparent;
          }

          #bar #start > *:not(:first-child) {
            margin-left: var(--spacing);
          } 

          #bar #end > *:not(:first-child) {
            margin-left: var(--spacing);
          }

          .widget {
            background-color: #${themePalette.background};
          }

          #power-btn {
            background-color: transparent;
            color: #${themePalette.image.red};
            border: 1px solid #${themePalette.image.red};
          }

          #power-btn:hover {
            background-color: #${themePalette.image.red};
            color: #${themePalette.dark.text};
          }

          #sysinfo {
            border: 1px solid #${themePalette.background-alt};
          }

          #sysinfo > * {
            margin-left: 0.5em;
            margin-right: 0.5em;
          }

          .workspaces .item {
            background-color: transparent;
          }

          .workspaces .item:hover {
            background-color: color-mix(in srgb, #${themePalette.background} 60%, #${themePalette.background-alt} 40%);
          }

          .workspaces .item.focused, .workspaces .item.visible {
            color: #${themePalette.accent};
            border: 0;
            border-bottom: .2em solid #${themePalette.accent};
            font-weight: normal;
          }

          .workspaces .item.urgent {
            color: #${themePalette.image.orange};
            border-bottom: .2em solid #${themePalette.image.orange};
          }

          .workspaces, #current-window, .volume, .tray, .clock, .notifications {
            border: 1px solid #${themePalette.background-alt};
          }

          #current-window {
            padding-left: 0.5em;
            padding-right: 0.5em;
          }

          .tray .item {
            background-color: transparent;
          }

          .tray .item:hover {
            background-color: color-mix(in srgb, #${themePalette.background} 60%, #${themePalette.background-alt} 40%);
          }

          .notifications .button {
            background-color: transparent;
          }

          .notifications .button:hover {
            background-color: color-mix(in srgb, #${themePalette.background} 60%, #${themePalette.background-alt} 40%);
          }
        '';
      };

      wayland.windowManager.niri.settings.binds."Mod+Delete".spawn = [
        "ironbar"
        "bar"
        bar-name
        "toggle-visible"
      ];
    };
}
