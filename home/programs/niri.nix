{ hostConfig, ... }:

let
  inherit (hostConfig) monitors;

  getMonitorWidth = mode: builtins.fromJSON (builtins.head (builtins.split "x" mode));
  foldedMonitors =
    builtins.foldl'
      ({ acc, x }: mon: {
        acc = acc ++ [
          (
            mon
            // {
              inherit x;
              y = 0;
            }
          )
        ];
        x = x + getMonitorWidth mon.mode;
      })
      {
        acc = [ ];
        x = 0;
      }
      monitors;
  positionedMonitors = foldedMonitors.acc;

  mkOutput =
    {
      name,
      mode,
      scale,
      x,
      y,
      ...
    }:
    ''
      output "${name}" {
          mode "${mode}"
          scale ${scale}
          transform "normal"
          position x=${toString x} y=${toString y}
          focus-at-startup
          hot-corners {
              off
          }
      }
    '';
in
{
  xdg.configFile = {
    "niri/config.kdl".text = ''
      ${builtins.readFile ./niri/config.kdl}
      ${builtins.concatStringsSep "\n" (map mkOutput positionedMonitors)}
    '';
    "niri/autostart.kdl".source = ./niri/autostart.kdl;
    "niri/input.kdl".source = ./niri/input.kdl;
    "niri/key-bindings.kdl".source = ./niri/key-bindings.kdl;
    "niri/layout.kdl".source = ./niri/layout.kdl;
    "niri/misc.kdl".source = ./niri/misc.kdl;
    "niri/window-rules.kdl".source = ./niri/window-rules.kdl;
    "niri/workspaces.kdl".source = ./niri/workspaces.kdl;
  };
}
