{
  catppuccinScss,
  monitors,
  lib,
  ...
}:
let
  widgetAutostart =
    wName:
    lib.map (m: {
      spawn-at-startup._args = [
        "eww"
        "open"
        "${wName}"
        "--id"
        "${wName}-${m.connector}"
        "--screen"
        "${m.connector}"
      ];
    }) monitors;
in
{
  programs.eww = {
    enable = true;
    systemd.enable = true;
    scssConfig = catppuccinScss {
      text = builtins.readFile ./resources/eww-style.scss;
    };
    yuckConfig = ''
      ${builtins.readFile ./resources/eww-config.yuck}
    '';
  };

  wayland.windowManager.niri.settings._children =
    (widgetAutostart "clock") ++ (widgetAutostart "calendar");
}
