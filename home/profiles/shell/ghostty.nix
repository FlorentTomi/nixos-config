{ ... }:

{
  programs.ghostty = {
    enable = true;
    settings.font-family = "JetBrainsMono Nerd Font";
    settings.background-opacity = 0.9;
    settings.copy-on-select = true;
  };

  wayland.windowManager.niri.settings.binds."Mod+Return".spawn = [ "ghostty" ];
  wayland.windowManager.niri.settings.binds."Mod+Escape".spawn = [
    "ghostty"
    "--confirm-close-surface=false"
    "-e"
    "btop"
  ];
}
