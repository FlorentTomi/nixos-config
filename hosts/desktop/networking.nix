{ ... }:
{
  networking.hostName = "ftomi-nixos";
  networking.networkmanager.enable = true;

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
