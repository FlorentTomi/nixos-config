{
  flake.modules.homeManager.ghostty =
    { pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;
        settings = {
          font-family = "JetBrainsMono Nerd Font";
          background-opacity = 0.9;
          copy-on-select = true;
          notify-on-command-finish = "unfocused";
        };
      };

      home.packages = [ pkgs.nirimon ];

      wayland.windowManager.niri.settings._children = [
        {
          window-rule._children = [
            {
              match._props.app-id = "ghostty$";
              background-effect = {
                blur = true;
              };
            }
          ];
        }
      ];

      wayland.windowManager.niri.settings.binds."Mod+Ctrl+Return".spawn = [ "ghostty" ];
    };
}
