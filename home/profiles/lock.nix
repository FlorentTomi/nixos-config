{ ... }:
{
  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ./lock/hyprlock.conf;
  };

  programs.niri.settings.binds."Mod+L".action.spawn = "hyprlock";
}
