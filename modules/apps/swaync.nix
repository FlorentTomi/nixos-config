{
  flake.modules.homeManager.swaync =
    { pkgs, themePalette, ... }:
    let
      colorPalette = {
        bg = "#${themePalette.background}";
        bgAlt = "#${themePalette.background-alt}";
        surface = "#${themePalette.background-selection}";
        border = "#${themePalette.popup.border-low-urgency}";
        fg = "#${themePalette.text}";
        fgMuted = "#${themePalette.popup.border-low-urgency}";
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
        pillBg = "${colorPalette.accent}";
        onAccent = "${colorPalette.bg}";
      };

    in
    {
      home.packages = [
        pkgs.sunsetr
      ];

      services.swaync = {
        enable = true;
        settings = {
          positionX = "right";
          positionY = "top";
          layer = "overlay";
          control-center-layer = "top";
          control-center-width = 380;
          control-center-margin-top = 8;
          control-center-margin-right = 10;
          notification-window-width = 380;
          notification-icon-size = 22;
          timeout = 6;
          timeout-low = 4;
          timeout-critical = 0;

          widgets = [
            "title"
            "buttons-grid"
            "mpris"
            "notifications"
          ];

          widget-config = {
            title = {
              text = "NOTIFICATIONS";
              clear-all-button = true;
              button-text = "clear all";
            };

            # The player is a vertical box with every child centred — art,
            # title, subtitle, transport, in that order — and CSS cannot
            # reorder or re-anchor them. So size the art to read as a
            # deliberate now-playing tile rather than a broken row.
            mpris = {
              image-size = 96;
              image-radius = 0;
            };

            buttons-grid = {
              actions = [
                {
                  label = "Do not disturb";
                  type = "toggle";
                  command = "swaync-client -d -sw";
                  update-command = "swaync-client -D";
                }
                {
                  label = "Night light";
                  type = "toggle";
                  command = "sh -c 'pgrep -x sunsetr && sunsetr stop || sunsetr -b'";
                  update-command = "sh -c 'pgrep -x sunsetr && echo true || echo false'";
                }
              ];
            };
          };
        };

        style = with colorPalette; ''
          * {
            font-family: "IBM Plex Sans", sans-serif;
            border-radius: 0;
            box-shadow: none;
          }

          .control-center {
            background: ${bg};
            border: 1px solid ${border};
            padding: 14px;
          }

          .control-center .notification-row { background: transparent; }

          .widget-title {
            color: ${warning};
            font-family: "JetBrains Mono", monospace;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.12em;
            padding: 0 0 12px 0;
          }

          .widget-title > button {
            font-family: "JetBrains Mono", monospace;
            font-size: 10.5px;
            font-weight: 400;
            color: ${fgMuted};
            background: transparent;
            border: none;
            padding: 2px 6px;
          }

          .widget-title > button:hover { color: ${fg}; background: ${surface}; }

          /* ---- toggle chips ------------------------------------------------ */
          .widget-dnd, .widget-buttons-grid { padding: 0 0 12px 0; background: transparent; }
          .widget-buttons-grid > flowbox > flowboxchild > button {
            background: ${surface};
            border: none;
            padding: 5px 10px;
            color: ${fgMuted};
            font-family: "JetBrains Mono", monospace;
            font-size: 10.5px;
          }
          .widget-buttons-grid > flowbox > flowboxchild > button:hover { background: ${border}; }
          .widget-buttons-grid > flowbox > flowboxchild > button.toggle:checked {
            background: ${surface};
            color: ${warning};
          }

          /* ---- MPRIS ------------------------------------------------------- */
          /* Centred stack, not a row. Art size comes from image-size in the
             widget config — -gtk-icon-size on .widget-mpris-album-art does
             nothing here. */
          .widget-mpris { background: transparent; padding: 0 0 12px 0; }
          .widget-mpris-player {
            background: ${surface};
            padding: 12px;
          }
          .widget-mpris-title {
            color: ${fg};
            font-size: 12.5px;
            font-weight: 600;
            padding: 9px 0 0 0;
          }
          .widget-mpris-subtitle {
            color: ${fgMuted};
            font-family: "JetBrains Mono", monospace;
            font-size: 10.5px;
          }
          .widget-mpris button { background: transparent; border: none; color: ${fgMuted}; padding: 0 8px; }
          .widget-mpris button:hover { color: ${accent6}; }
          .widget-mpris button:disabled { color: ${border}; }
          /* The player-paging arrows, shown only with two or more players. */
          .widget-mpris > box > button { color: ${border}; padding: 0 4px; }
          .widget-mpris > box > button:hover { color: ${fg}; background: transparent; }

          /* ---- notification rows ------------------------------------------- */
          .notification {
            background: ${surface};
            border-left: 2px solid ${accent};
            padding: 0;
            margin: 0 0 6px 0;
          }
          .notification.low       { border-left-color: ${border}; }
          .notification.critical  { border-left-color: ${danger}; }
          .notification-content { padding: 11px 12px; background: transparent; }
          .summary { color: ${fg}; font-size: 12.5px; font-weight: 600; }
          .body    { color: ${fgMuted}; font-size: 11.5px; }
          .time    { color: ${fgMuted}; font-family: "JetBrains Mono", monospace; font-size: 10px; }
          .close-button {
            background: transparent;
            border: none;
            color: ${fgMuted};
            padding: 4px;
          }
          .close-button:hover { color: ${danger}; background: ${border}; }
          .notification-action {
            background: ${border};
            border: none;
            color: ${fg};
            padding: 6px 10px;
          }
          .notification-action:hover { background: ${pillBg}; color: ${onAccent}; }

          /* ---- floating toast ---------------------------------------------- */
          .floating-notifications .notification {
            background: ${bg};
            border: 1px solid ${border};
            border-left: 2px solid ${accent};
          }
          .floating-notifications .notification.critical { border-left-color: ${danger}; }
          .floating-notifications .notification.low { border-left-color: ${border}; }
        '';
      };
    };
}
