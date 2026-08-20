{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.virtualisation;
in
{
  options.modules.virtualisation = {
    enable = lib.mkEnableOption "Docker container runtime and related tooling";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Users to add to the docker group.";
      example = [ "ftomi" ];
    };

    nvidia = lib.mkEnableOption "NVIDIA Container Toolkit (GPU passthrough into containers via CDI)";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    hardware.nvidia-container-toolkit.enable = cfg.nvidia;
    systemd.services.nvidia-container-toolkit-cdi-generator = {
      restartIfChanged = false;
    };

    users.groups.docker.members = cfg.users;

    environment.systemPackages = with pkgs; [
      docker-compose
      docker-buildx
      lazydocker
    ];
  };
}
