{ config, lib, pkgs, ... }:
let
  cfg = config.modules.nvidia;
in
{
  options.modules.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU support (open kernel module, Wayland/DRM tweaks, nvtop)";

    powerManagement = lib.mkEnableOption "NVIDIA runtime power management (only needed for laptops/Optimus setups)";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = cfg.powerManagement;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    environment.systemPackages = [
      pkgs.nvtopPackages.nvidia
    ];
  };
}
