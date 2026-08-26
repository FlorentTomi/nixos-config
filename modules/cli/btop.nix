{
  flake.modules.homeManager.btop = {
    programs.btop.enable = true;

    wayland.windowManager.niri.settings._children = [
      {
        window-rule._children = [
          {
            match._props.title = "^btop$";
            open-floating = true;
            default-column-width.proportion = 0.6;
            default-window-height.proportion = 0.7;
          }
        ];
      }
    ];

    wayland.windowManager.niri.settings.binds."Mod+Escape".spawn = [
      "ghostty"
      "--title=btop"
      "--confirm-close-surface=false"
      "-e"
      "btop"
    ];
  };
}
