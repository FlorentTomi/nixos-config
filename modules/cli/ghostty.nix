{
  homeManager.modules.ghostty =
    { pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;
        settings.font-family = "JetBrainsMono Nerd Font";
        settings.background-opacity = 0.9;
        settings.copy-on-select = true;
      };

      home.packages = [ pkgs.nirimon ];

      wayland.windowManager.niri.settings._children = [
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "ghostty$";
              };
            }
            {
              background-effect = {
                blur = true;
              };
            }
          ];
        }
      ];

      wayland.windowManager.niri.settings.binds."Mod+Return".spawn = [ "ghostty" ];

      wayland.windowManager.niri.settings.binds."Mod+Escape".spawn = [
        "ghostty"
        "--confirm-close-surface=false"
        "-e"
        "btop"
      ];

      wayland.windowManager.niri.settings.binds."Mod+P".spawn = [
        "ghostty"
        "--confirm-close-surface=false"
        "-e"
        "nirimon"
      ];
    };
}
