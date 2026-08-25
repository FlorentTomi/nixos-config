{
  flake.modules.nixos.networking = {
    networking.networkmanager.enable = true;
    networking.networkmanager.dns = "systemd-resolved";

    services.resolved.enable = true;
  };

  flake.modules.homeManager.networking = {
    services.network-manager-applet.enable = true;
  };
}
