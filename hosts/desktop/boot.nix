{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = false;
  boot.loader.limine.enable = true;
  boot.loader.limine.maxGenerations = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [ "amd_pstate=active" ];

  environment.systemPackages = with pkgs; [ lm_sensors ];

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };

  powerManagement.cpuFreqGovernor = "powersave";

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };
}
