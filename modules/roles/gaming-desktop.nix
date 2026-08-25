{ config, ... }:
{
  flake.modules.nixos.gaming-desktop.imports = with config.flake.modules.nixos; [
    steam
    gamemode
    sunshine
    coolercontrol
    via
    wifi-performance
  ];

  flake.modules.homeManager.gaming-desktop.imports = with config.flake.modules.homeManager; [
    steam
    lutris
    prismlauncher
    mangohud
    heroic
    moonlight
  ];
}
