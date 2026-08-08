{ ... }:
{
  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ./resources/hyprlock-config.conf;
  };

  wayland.windowManager.niri.settings.binds."Mod+L".spawn = [ "hyprlock" ];
}
