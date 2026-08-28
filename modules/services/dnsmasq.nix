{
  flake.modules.nixos.dnsmasq = {
    services.dnsmasq = {
      enable = true;
      settings = {
        no-resolv = true;
        no-hosts = true;
        interface = "tailscale0";
        bind-interfaces = true;
        address = "/ftomi-rpi.net/100.112.219.126";
        server = [
          "1.1.1.1"
          "9.9.9.9"
        ];
      };
    };
  };
}
