{
  flake.modules.nixos.bootloader = {
    boot.loader = {
      systemd-boot.enable = false;
      limine.enable = true;
      limine.maxGenerations = 10;
      efi.canTouchEfiVariables = true;
    };
  };
}
