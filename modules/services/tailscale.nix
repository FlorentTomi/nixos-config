{
  flake.modules.nixos.tailscale = {
    services.tailscale = {
      enable = true;
      extraSetFlags = [ "--netfilter-mode=off" ];
    };

    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };

  flake.modules.homeManager.tailscale = {
    services.tailscale-systray.enable = true;
  };
}
