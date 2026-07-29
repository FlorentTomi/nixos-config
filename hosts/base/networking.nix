{ ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  services.resolved.enable = true;

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--netfilter-mode=off" ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
