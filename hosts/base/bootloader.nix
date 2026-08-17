{ ... }:
{
  boot.loader.systemd-boot.enable = false;
  boot.loader.limine.enable = true;
  boot.loader.limine.maxGenerations = 10;
  boot.loader.efi.canTouchEfiVariables = true;
}
