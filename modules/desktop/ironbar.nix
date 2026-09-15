{
  flake.modules.homeManager.ironbar =
    { inputs, themePalette, ... }:
    let
      bar-name = "main";

      separator = {
        type = "label";
        name = "sep";
        label = "󱋱";
      };

      powerBar = {
        type = "custom";
        class = "power-menu";
        bar = [
          {
            type = "button";
            name = "power-btn";
            label = "󰍃";
            on_click = "!wleave";
          }
        ];
      };

      sysInfo = {
        type = "sys_info";
        name = "stats";

        interval = {
          cpu = 2;
          temps = 5;
          memory = 15;
          disks = 300;
        };

        format = [
          "CPU"
          "{cpu_percent}%"
          "TEMP"
          "{temp_c@k10temp Tctl}°C"
          "RAM"
          "{memory_percent}%"
          "DISK"
          "{disk_free@/#G}G free"
        ];
      };

      workspaces = {
        type = "workspaces";
        name = "ws";
        all_monitors = false;
      };

      currentWindow = {
        type = "focused";
        name = "cur-win";
        show_icon = true;
        icon_size = 16;
        truncate = {
          mode = "end";
        };
      };

      volume = {
        type = "volume";
        name = "vol";
      };

      tray = {
        type = "tray";
        name = "tray";
        icon_size = 14;
      };

      dateTime = {
        type = "clock";
        name = "clock";
        format = "%a %d %b <b>%H:%M</b>";
        format_popup = "%H:%M:%S";
      };

      notifications = {
        type = "notifications";
        name = "notif";
        show_count = false;
      };

      colorPalette = {
        bg = "#${themePalette.background}";
        bgAlt = "#${themePalette.background-alt}";
        surface = "#${themePalette.background-selection}";
        border = "#${themePalette.popup.border-low-urgency}";
        fg = "#${themePalette.text}";
        fgMuted = "color-mix(in srgb, #${colorPalette.fg} 72%, #${colorPalette.bg} 28%)";
        accent = "#${themePalette.accent}";
        accent1 = "#${themePalette.accent}";
        accent2 = "#${themePalette.image.orange}";
        accent3 = "#${themePalette.image.green}";
        accent4 = "#${themePalette.image.cyan}";
        accent5 = "#${themePalette.image.cyan}";
        accent6 = "#${themePalette.image.purple}";
        accent7 = "#${themePalette.image.purple}";
        warning = "#${themePalette.image.yellow}";
        danger = "#${themePalette.image.red}";
        pillBg = "#${colorPalette.bg}";
        onAccent = "#${colorPalette.accent}";
      };

      style = with colorPalette; ''
        * {
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 11px;
          font-weight: bold;
          border-radius: 0;
          box-shadow: none;
          min-height: 0;
          min-width: 0;
        }

        .background { background: transparent; }

        #start, #end, #cur-win {
          background-color: ${bg};
          border: 1px solid ${border};
          padding: 3px;
        }

        #center { background-color: transparent; border: 0; }

        .widget { background-color: transparent; border: 0; color: ${fg}; }

        #bar #start > *:not(:first-child),
        #bar #end   > *:not(:first-child) { margin-left: 8px; }

        .power-menu #power-btn { 
          color: ${danger}; 
          background-color: transparent; 
          border: 1px inset ${danger}; 
        }
        
        .power-menu #power-btn:hover { background-color: ${danger}; color: ${bg};  }

        #stats > * { color: ${fgMuted}; }
        #stats > *:nth-child(odd)  { margin-left: 0.7em; margin-right: 0.25em; }
        #stats > *:nth-child(even) { margin-right: 0.7em; font-weight: normal; }
        #stats > *:nth-child(1) { color: ${accent1}; }
        #stats > *:nth-child(3) { color: ${accent2}; }
        #stats > *:nth-child(5) { color: ${accent3}; }
        #stats > *:nth-child(7) { color: ${accent4}; }

        #stats.hot > *:nth-child(3),
        #stats.hot > *:nth-child(4) { color: ${danger}; }

        .workspaces .item {
          background-color: transparent;
          color: ${fgMuted};
          padding: 0 9px;
          border: 0;
        }

        .workspaces .item:hover { background-color: ${surface}; }
        .workspaces .item.focused,
        .workspaces .item.visible {
          background-color: ${accent};
          color: ${bg};
        }

        .workspaces .item.urgent { background-color: transparent; color: ${warning}; }

        #cur-win { padding: 0 0.5em; }
        #cur-win label { color: ${fg}; font-weight: normal; margin: 0; padding: 0 0.25em; }
        #cur-win image { -gtk-icon-size: 16px; margin: 0; padding: 0; }
        #cur-win box { padding: 0; margin: 0; }

        #vol { 
          padding: 0 0.6em; 
          color: ${fgMuted};
          background-color: transparent; 
          border: 0; 
        }

        #vol .source {
          padding-left: 0.5em;
        }

        .clock { padding: 0 0.7em; color: ${fg}; }

        .tray { padding: 0 0.3em; }
        .tray .item { background-color: transparent; padding: 0 0.3em; }
        .tray .item:hover { background-color: ${surface}; }
        .tray image { -gtk-icon-size: 16px; }

        .notifications .button { 
          background-color: transparent; 
          color: ${fgMuted};
          border: 1px inset ${border}; 
        }
        
        .notifications .button:hover { background-color: ${surface}; }
        .notifications .count-positive { color: ${warning}; }

        .popup {
          background-color: ${bg};
          border: 1px solid ${border};
          padding: 14px;
        }

        .popup-clock .calendar-clock { color: ${accent}; }
        .popup-clock calendar { background-color: transparent; color: ${fg}; }
        .popup-clock calendar:selected { background-color: ${pillBg}; color: ${onAccent}; }

        #vol-slider trough    { background-color: ${surface}; min-height: 6px; }
        #vol-slider highlight { background-color: ${accent6}; }
        #vol-slider slider    { background-color: ${accent6}; min-width: 12px; min-height: 12px; }

        .popup button { padding: 7px 10px; color: ${fg}; background-color: transparent; border: 0; }
        .popup button:hover { background-color: ${surface}; }
      '';
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

        style = style;
        config = {
          name = bar-name;
          position = "top";
          height = 26;
          anchor_to_edges = true;
          popup_autohide = true;
          icon_theme = "Papirus-Dark";

          margin = {
            top = 8;
            left = 8;
            right = 8;
          };

          start = [
            powerBar
            separator
            sysInfo
            separator
            workspaces
          ];

          center = [
            currentWindow
          ];

          end = [
            volume
            separator
            tray
            separator
            dateTime
            separator
            notifications
          ];
        };
      };

      wayland.windowManager.niri.settings.binds."Mod+Delete".spawn = [
        "ironbar"
        "bar"
        bar-name
        "toggle-visible"
      ];
    };
}
