{ ... }:
{
  imports = [
    # shared across any host
    ../base/nix.nix
    ../base/audio.nix
    ../base/portals.nix
    ../base/boot.nix
    ../base/networking.nix
    ../base/display-manager.nix
    ../base/sops.nix
    ../base/nix-utils.nix

    # personal preferences, same across any host you'd use
    ../../profiles/ftomi/locale.nix
    ../../profiles/ftomi/stylix.nix
    ../../profiles/ftomi/login-theme.nix

    # optional, hardware-dependent modules (toggled below)
    ../../modules/nvidia.nix
    ../../modules/niri.nix
    ../../modules/openvpn.nix

    # this exact machine
    ./hardware-configuration.nix
    ./disko-config.nix
    ./users.nix
    ./boot.nix
    ./networking.nix
    ./storage.nix
    ./snapshots.nix
    ./system.nix
    ./gaming.nix
  ];

  modules.nvidia.enable = true;
  modules.niri.enable = true;
  modules.openvpn = {
    enable = true;
    configs = [
      {
        name = "pytheas_prod";
        hasAuth = true;
      }
      {
        name = "pytheas_infra";
        hasAuth = true;
      }
    ];
  };

  sops.defaultSopsFile = ./secrets.yaml;

  system.stateVersion = "26.05";
}
