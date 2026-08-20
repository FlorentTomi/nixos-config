{
  nixos.modules.networking = {
    networking.networkmanager.enable = true;
    networking.networkmanager.dns = "systemd-resolved";

    services.resolved.enable = true;
  };

  homeManager.modules.networking = {
    services.network-manager-applet.enable = true;
  };
}
