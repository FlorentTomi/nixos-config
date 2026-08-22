{
  homeManager.modules.btop = {
    programs.btop.enable = true;
    
    wayland.windowManager.niri.settings.binds."Mod+Escape".spawn = [
      "ghostty"
      "--confirm-close-surface=false"
      "-e"
      "btop"
    ];
  };
}
