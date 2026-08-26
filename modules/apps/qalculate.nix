{
  flake.modules.homeManager.qalculate =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.qalculate-gtk ];
      wayland.windowManager.niri.settings._children = [
        {
          window-rule._children = [
            {
              match._props.app-id = "^qalculate";
              open-floating = true;
            }
          ];
        }
      ];
    };
}
