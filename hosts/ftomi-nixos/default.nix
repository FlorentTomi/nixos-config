{ ... }:
{
  imports = [
    # shared across any host
    ../../common/nix.nix
    ../../common/audio.nix
    ../../common/users.nix
    ../../common/portals.nix
    ../../common/boot.nix
    ../../common/networking.nix
    ../../common/display-manager.nix
    ../../common/gaming.nix
    ../../common/sops.nix
    ../../common/nix-ld.nix

    # personal preferences, same across any host you'd use
    ../../profiles/ftomi/locale.nix
    ../../profiles/ftomi/stylix.nix
    ../../profiles/ftomi/login-theme.nix

    # optional, hardware-dependent modules (toggled below)
    ../../modules/nvidia.nix

    # this exact machine
    ./hardware-configuration.nix
    ./boot.nix
    ./networking.nix
    ./storage.nix
    ./snapshots.nix
    ./system.nix
  ];

  modules.nvidia.enable = true;
  sops.defaultSopsFile = ./secrets.yaml;

  system.stateVersion = "26.05";
}
