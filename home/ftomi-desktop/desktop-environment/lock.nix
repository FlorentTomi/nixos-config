{ ... }:
{
  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ./lock/hyprlock.conf;
  };
}
