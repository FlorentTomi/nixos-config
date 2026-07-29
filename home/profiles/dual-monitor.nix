# This machine's specific monitor topology (4K primary + 144Hz secondary).
# Not portable to other hardware — kept as an opt-in profile rather than in
# niri-core so a host with different/no external monitors doesn't inherit it.
{ ... }:
{
  programs.niri.settings.outputs = {
    "DP-1" = {
      mode = {
        width = 3840;
        height = 2160;
        refresh = 59.997;
      };
      scale = 1.0;
      position = {
        x = 0;
        y = 0;
      };
      focus-at-startup = true;
    };
    "HDMI-A-1" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 144.001;
      };
      scale = 1.0;
      position = {
        x = 3840;
        y = 0;
      };
      focus-at-startup = false;
    };
  };
}
