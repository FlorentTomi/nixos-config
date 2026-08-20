{
  nixos.modules.virtualisation =
    { config, lib, pkgs, ... }:
    let
      cfg = config.custom.virtualisation;
    in
    {
      options.custom.virtualisation = {
        dockerUsers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "ftomi" ];
          description = "Users to add to the docker group.";
        };

        nvidiaContainerToolkit = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "NVIDIA Container Toolkit (GPU passthrough into containers via CDI).";
        };
      };

      config = {
        virtualisation.docker = {
          enable = true;
          autoPrune = {
            enable = true;
            dates = "weekly";
          };
        };

        hardware.nvidia-container-toolkit.enable = cfg.nvidiaContainerToolkit;
        systemd.services.nvidia-container-toolkit-cdi-generator = {
          restartIfChanged = false;
        };

        users.groups.docker.members = cfg.dockerUsers;

        environment.systemPackages = with pkgs; [
          docker-compose
          docker-buildx
          lazydocker
        ];
      };
    };
}
