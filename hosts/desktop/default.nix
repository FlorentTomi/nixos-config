{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./stylix.nix
    ./gaming.nix
    ./boot.nix
    ./networking.nix
    ./locale.nix
    ./nix.nix
    ./users.nix
    ./display-manager.nix
    ./portals.nix
    ./storage.nix
    ./audio.nix
    ./snapshots.nix
  ];

  system.stateVersion = "26.05";
}
