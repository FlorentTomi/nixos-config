{ ... }:
{
  imports = [
    # shared across any host
    ../base/nix.nix
    ../base/pipewire.nix
    ../base/dconf.nix
    ../base/xdg-portal.nix
    ../base/bootloader.nix
    ../base/zram.nix
    ../base/networkmanager.nix
    ../base/tailscale.nix
    ../base/sops.nix
    ../base/nix-ld.nix
    ../base/envfs.nix
    ../base/btrbk.nix

    # personal preferences, same across any host you'd use
    ../../profiles/ftomi/locale.nix

    # optional, hardware-dependent modules (toggled below)
    ../../modules/nvidia.nix
    ../../modules/niri.nix
    ../../modules/openvpn.nix
    ../../modules/console.nix
    ../../modules/virtualisation.nix
    ../../modules/ollama.nix

    # this exact machine
    ../profiles/sddm.nix
    ./hardware-configuration.nix
    ./disko-config.nix
    ./users.nix
    ./boot.nix
    ./networking.nix
    ./fstrim.nix
    ./smartd.nix
    ./coolercontrol.nix
    ./via.nix
    ./bluetooth.nix
    ./openvpn-polkit.nix
    ./steam.nix
    ./gamemode.nix
    ./sunshine.nix
  ];

  modules.nvidia.enable = true;
  modules.niri.enable = true;
  # modules.ollama.enable = true;
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
