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
        hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
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
        "mpris"
        "tray"
        "group/volume"
        "clock"
      ];
      mpris = {
        artist-len = 20;
        title-len = 10;
        format = "{player_icon} {dynamic}";
        format-paused = "{status_icon} <i>{dynamic}</i>";
        dynamic-order = [
          "artist"
          "title"
        ];
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
      "group/volume" = {
        orientation = "inherit";
        drawer= {
            transition-duration= 500;
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
