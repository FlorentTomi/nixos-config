{ pkgs, ... }:

{
  programs.discord.enable = true;

  home.packages = [
    pkgs.tailscale
    pkgs.scrcpy
    pkgs.android-tools
    pkgs.floorp-bin
  ];

  services = {
    tailscale-systray.enable = true;
  };
}
