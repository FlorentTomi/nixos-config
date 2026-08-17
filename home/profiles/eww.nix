{
  catppuccinScss,
  monitors,
  lib,
  ...
}:
let
  widgetAutostart =
    wName:
    lib.map (mName: {
      spawn-at-startup._args = [
        "eww"
        "open"
        "${wName}"
        "--screen"
        "${mName}"
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
