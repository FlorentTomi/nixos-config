# This machine's specific monitor topology (4K primary + 144Hz secondary).
# Not portable to other hardware — kept as an opt-in profile rather than in
# home/ftomi/niri.nix so a host with different/no external monitors doesn't inherit it.
{ lib, ... }:

let
  monitors = [
    {
      connector = "HDMI-A-1";
      model = "Acer XZ271";
      scale = 1.0;
      mode = {
        width = 1920;
        height = 1080;
        framerate = 144;
      };
      primary = false;
      position = {
        x = 3840;
        y = 0;
      };
    }
    {
      connector = "DP-1";
      model = "U32R59x";
      scale = 1.0;
      mode = {
        width = 3840;
        height = 2160;
        framerate = 60;
      };
      primary = true;
      position = {
        x = 0;
        y = 0;
      };
    }
  ];

  niriOutputs = lib.map (monitor: {
    output = {
      _args = [ monitor.connector ];
      scale = monitor.scale;
      ${if monitor.primary then "focus-at-startup" else null} = {};
      position._props = {
        x = monitor.position.x;
        y = monitor.position.y;
      };
      mode = "${toString monitor.mode.width}x${toString monitor.mode.height}@${toString monitor.mode.framerate}";
    };
  }) monitors;
in
{
  _module.args = {
    monitors = monitors;
  };

  # wayland.windowManager.niri.settings is freeform/generic KDL, not
  # niri-flake's typed `outputs` schema — niri's `output` node is a repeated
  # top-level node (name as an argument, not an attrset key), so each
  # monitor goes through the root `_children` list, and `mode` is niri's
  # single "WIDTHxHEIGHT@REFRESH" string rather than a structured attrset.
  # focus-at-startup is a flag node: present only for the output that
  # should have it (DP-1); omitted entirely for HDMI-A-1, since niri
  # defaults it to off.
  wayland.windowManager.niri.settings._children = niriOutputs;
}
