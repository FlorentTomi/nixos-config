{
  nixos.modules.tailscale = {
    services.tailscale = {
      enable = true;
      extraSetFlags = [ "--netfilter-mode=off" ];
    };

    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };

  homeManager.modules.tailscale = {
    services.tailscale-systray.enable = true;
  };
}
