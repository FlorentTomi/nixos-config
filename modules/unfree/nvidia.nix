{
  flake.modules.nixos.nvidia =
    { config, pkgs, ... }:
    {
      boot.kernelParams = [
        "nvidia-drm.modeset=1"
        "nvidia-drm.fbdev=1"
      ];

      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      hardware.nvidia = {
        modesetting.enable = true;
        # laptop/Optimus hosts wanting runtime power management can set
        # hardware.nvidia.powerManagement.enable = true; directly.
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      environment.systemPackages = [
        pkgs.nvtopPackages.nvidia
      ];
    };
}
