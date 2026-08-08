# This machine's specific monitor topology (4K primary + 144Hz secondary).
# Not portable to other hardware — kept as an opt-in profile rather than in
# niri-core so a host with different/no external monitors doesn't inherit it.
{ ... }:
{
  # wayland.windowManager.niri.settings is freeform/generic KDL, not
  # niri-flake's typed `outputs` schema — niri's `output` node is a repeated
  # top-level node (name as an argument, not an attrset key), so each
  # monitor goes through the root `_children` list, and `mode` is niri's
  # single "WIDTHxHEIGHT@REFRESH" string rather than a structured attrset.
  # focus-at-startup is a flag node: present only for the output that
  # should have it (DP-1); omitted entirely for HDMI-A-1, since niri
  # defaults it to off.
  wayland.windowManager.niri.settings._children = [
    {
      output = {
        _args = [ "DP-1" ];
        scale = 1.0;
        focus-at-startup = { };
        position._props = {
          x = 0;
          y = 0;
        };
        mode = "3840x2160@59.997";
      };
    }
    {
      output = {
        _args = [ "HDMI-A-1" ];
        scale = 1.0;
        position._props = {
          x = 3840;
          y = 0;
        };
        mode = "1920x1080@144.001";
      };
    }
  ];
}
