{
  flake.modules.homeManager.swaync =
    { themePalette, ... }:
    {
      services.swaync = {
        enable = true;
        settings = {
          positionX = "right";
          positionY = "top";
          control-center-positionX = "none";
          control-center-positionY = "none";
          control-center-margin-top = 4;
          control-center-margin-bottom = 4;
          control-center-margin-right = 4;
          control-center-margin-left = 4;
          control-center-width = 500;
          control-center-height = -1;
          fit-to-screen = true;
          layer-shell-cover-screen = true;

          layer-shell = true;
          layer = "overlay";
          control-center-layer = "overlay";
          cssPriority = "user";
          notification-body-image-height = 100;
          notification-body-image-width = 200;
          notification-inline-replies = true;
          timeout = 10;
          timeout-low = 5;
          timeout-critical = 0;
          notification-window-width = 500;
          keyboard-shortcuts = true;
          image-visibility = "always";
          transition-time = 200;
          hide-on-clear = true;
          hide-on-action = true;
          script-fail-notify = true;

          widgets = [
            "mpris"
            "notifications"
          ];

          widget-config = {
            title = {
              text = "Notifications";
              clear-all-button = false;
              button-text = "Clear All";
            };

            mpris = {
              autohide = true;
            };

            notifications = {
              vexpand = false;
            };
          };
        };
        style = ''
          .widgets > .widget,
          .widget-mpris > carouselindicatordots,
          .widget-mpris > box > button {
            background: #${themePalette.background};
          }
          
          .notification-group {
            padding: 4px;
          }
          
          .widget.widget-mpris {
            background: transparent;
          }
          
          .widget-mpris > box > button:hover {
            background: #${themePalette.background-alt};
          }
        '';
      };
    };
}
