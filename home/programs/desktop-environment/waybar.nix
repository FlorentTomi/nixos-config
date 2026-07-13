{ lib, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = lib.mkAfter ''
      ${builtins.readFile ./waybar/style.css}
    '';

    settings.mainBar = {
      layer = "bottom";
      position = "top";
      exclusive = true;

      modules-left = [
        "custom/power"
        "cpu"
        "temperature"
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
      };
      temperature = {
        interval = 5;
        critical-threshold = 100;
        hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
        input-filename = "temp1_input";
        format = " {temperatureC}°C";
      };
      memory = {
        interval = 5;
        format = "  {percentage}%";
      };
      disk = {
        interval = 30;
        format = "󰋊 {percentage_used}% (Free: {free})";
      };

      modules-center = [ "niri/window" ];
      "niri/window" = {
        separate-outputs = true;
        icon = true;
      };

      modules-right = [
        "mpris"
        "tray"
        "pulseaudio"
        "clock"
      ];
      mpris = {
        artist-len = 20;
        title-len = 10;
        format = "{player_icon} {dynamic}";
        format-paused = "{status_icon} <i>{dynamic}</i>";
        dynamic-order = [ "artist" "title" ];
        player-icons = {
          default = "▶";
          mpv = "🎵";
        };
        status-icons = {
          paused = "⏸";
        };
      };
      tray = {
        spacing = 4;
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "";
        format-icons = {
          default = " ";
        };
        on-click = "pamixer -t";
        on-click-right = "pavucontrol";
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
            months = "<span color='#ffead3'><b>{}</b></span>";
            days = "<span color='#ecc6d9'><b>{}</b></span>";
            weeks = "<span color='#99ffdd'><b>W{}</b></span>";
            weekdays = "<span color='#ffcc66'><b>{}</b></span>";
            today = "<span color='#ff6699'><b><u>{}</u></b></span>";
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
