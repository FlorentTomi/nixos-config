{ ... }:
{
  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--netfilter-mode=off" ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
