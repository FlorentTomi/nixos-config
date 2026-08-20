{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = false;
  boot.loader.limine.enable = true;
  boot.loader.limine.maxGenerations = 10;
  boot.loader.limine.style.wallpapers = [
    pkgs.nixos-artwork.wallpapers.simple-dark-gray-bootloader.gnomeFilePath
  ];
  boot.loader.efi.canTouchEfiVariables = true;
}
