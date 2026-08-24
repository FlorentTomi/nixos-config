{
  nixos.modules.dnsmasq =
    { ... }:
    {
      services.dnsmasq = {
        enable = true;
        settings = {
          no-resolv = true;
          no-hosts = true;
          interface = "tailscale0";
          bind-interfaces = true;
          # Tailscale IP of this node; used as Split DNS target for *.ftomi-rpi.net
          # in the Tailscale admin console (DNS settings).
          address = "/ftomi-rpi.net/100.112.219.126";
        };
      };
    };
}
