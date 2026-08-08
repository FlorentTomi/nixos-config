{ ... }:
{
  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ./resources/hyprlock-config.conf;
  };

  programs.niri.settings.binds."Mod+L".action.spawn = "hyprlock";
}
