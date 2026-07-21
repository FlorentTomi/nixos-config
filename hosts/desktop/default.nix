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

    # personal preferences, same across any host you'd use
    ../../profiles/ftomi/locale.nix
    ../../profiles/ftomi/stylix.nix
    ../../profiles/ftomi/display-manager.nix

    # optional features
    ../../modules/gaming.nix

    # this exact machine
    ./hardware-configuration.nix
    ./nvidia.nix
    ./boot.nix
    ./networking.nix
    ./storage.nix
    ./snapshots.nix
    ./system.nix
  ];

  system.stateVersion = "26.05";
}
