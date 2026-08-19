{
  catppuccinScss,
  monitors,
  lib,
  pkgs,
  ...
}:
let
  concatDir =
    dir: ext:
    let
      entries = builtins.readDir dir;
      matching = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ext name) entries;
      names = lib.sort (a: b: a < b) (builtins.attrNames matching);
    in
    lib.concatMapStrings (name: builtins.readFile (dir + "/${name}") + "\n") names;

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
  home.packages = [
    pkgs.jq
    pkgs.curl
  ];

  home.file.".config/eww/scripts" = {
    source = ./resources/eww/scripts;
    recursive = true;
    executable = true;
  };

  programs.eww = {
    enable = true;
    systemd.enable = true;
    scssConfig = catppuccinScss {
      text = concatDir ./resources/eww/styles ".scss";
    };
    yuckConfig = concatDir ./resources/eww/widgets ".yuck";
  };

  wayland.windowManager.niri.settings._children = lib.concatMap widgetAutostart [
    "dashboard"
  ];
}
