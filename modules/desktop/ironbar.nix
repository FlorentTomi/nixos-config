{
  flake.modules.homeManager.ironbar =
    { inputs, themePalette, ... }:
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
          anchor_to_edges = true;
          popup_autohide = true;
          height = 20;
          position = "top";
          margin.top = 4;
          margin.left = 4;
          margin.right = 4;

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
              icon_size = 16;
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
              show_sources = false;
            }
            {
              type = "tray";
              icon_size = 16;
            }
            {
              type = "clock";
              format = " %Y/%m/%d  %H:%M";
              format_popup = "%H:%M";
            }
          ];
        };

        style = ''
          :root {
            --spacing: 4px;
          }

          * {
            font-family: "JetBrainsMono Nerd Font";
            border-radius: 0;
            box-shadow: none;
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
            border-color: #${themePalette.image.red};
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

          #cpu {
            color: #${themePalette.image.orange};
          }

          #temperature {
            color: #${themePalette.image.yellow};
          }

          #memory {
            color: #${themePalette.image.green};
          }

          #disk {
            color: #${themePalette.image.cyan};
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

          #power-btn, .workspaces, #current-window, .volume, .tray, .clock {
            border: 1px solid #${themePalette.background-alt};
          }

          #current-window {
            padding-left: 1em;
            padding-right: 1em;
          }

          .tray .item {
            background-color: transparent;
          }

          .tray .item:hover {
            background-color: color-mix(in srgb, #${themePalette.background} 60%, #${themePalette.background-alt} 40%);
          }
        '';
      };
    };
}
