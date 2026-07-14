{ ... }:
{
  networking.hostName = "ftomi-nixos";
  networking.networkmanager.enable = true;

  security.rtkit.enable = true;

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
}
