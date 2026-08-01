{ ... }:
{
  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ./resources/lock_hyprlock.conf;
  };

  programs.niri.settings.binds."Mod+L".action.spawn = "hyprlock";
}
