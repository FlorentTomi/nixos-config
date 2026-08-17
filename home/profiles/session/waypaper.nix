{ pkgs, ... }:

{
  home.packages = [ pkgs.waypaper ];

  wayland.windowManager.niri.settings._children = [
    {
      spawn-at-startup._args = [
        "waypaper"
        "--restore"
      ];
    }
  ];
}
