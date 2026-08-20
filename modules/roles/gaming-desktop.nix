{ config, ... }:
{
  nixos.modules.gaming-desktop.imports = with config.nixos.modules; [
    steam
    gamemode
    sunshine
    coolercontrol
    via
    wifi-performance
  ];

  homeManager.modules.gaming-desktop.imports = with config.homeManager.modules; [
    steam
    lutris
    prismlauncher
    mangohud
    heroic
    moonlight
  ];
}
