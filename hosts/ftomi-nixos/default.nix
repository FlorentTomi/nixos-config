{ ... }:
{
  imports = [
    # shared across any host
    ../base/nix.nix
    ../base/audio.nix
    ../base/portals.nix
    ../base/boot.nix
    ../base/networking.nix
    ../base/sops.nix
    ../base/nix-utils.nix
    ../base/snapshots.nix

    # personal preferences, same across any host you'd use
    ../../profiles/ftomi/locale.nix

    # optional, hardware-dependent modules (toggled below)
    ../../modules/nvidia.nix
    ../../modules/niri.nix
    ../../modules/openvpn.nix
    ../../modules/console.nix
    ../../modules/virtualisation.nix

    # this exact machine
    ../profiles/sddm.nix
    ./hardware-configuration.nix
    ./disko-config.nix
    ./users.nix
    ./boot.nix
    ./networking.nix
    ./storage.nix
    ./system.nix
    ./gaming.nix
  ];

  modules.nvidia.enable = true;
  modules.niri.enable = true;
  modules.virtualisation = {
    enable = true;
    users = [ "ftomi" ];
    nvidia = true;
  };

  modules.console = {
    enable = true;
    backend = "kmscon";
  };

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
