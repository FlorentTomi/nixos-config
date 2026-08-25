{
  flake.modules.homeManager.swayosd = {
    services.swayosd.enable = true;

    wayland.windowManager.niri.settings.binds = {
      "XF86AudioRaiseVolume".spawn = [
        "swayosd-client"
        "--output-volume"
        "raise"
      ];

      "XF86AudioLowerVolume".spawn = [
        "swayosd-client"
        "--output-volume"
        "lower"
      ];

      "XF86AudioMute".spawn = [
        "swayosd-client"
        "--output-volume"
        "mute-toggle"
      ];

      "XF86AudioMicMute".spawn = [
        "swayosd-client"
        "--input-volume"
        "mute-toggle"
      ];

      "XF86AudioPlay".spawn = [
        "swayosd-client"
        "--playerctl"
        "play-pause"
      ];

      "XF86AudioStop".spawn = [
        "swayosd-client"
        "--playerctl"
        "stop"
      ];

      "XF86AudioPrev".spawn = [
        "swayosd-client"
        "--playerctl"
        "prev"
      ];

      "XF86AudioNext".spawn = [
        "swayosd-client"
        "--playerctl"
        "next"
      ];
    };
  };
}
