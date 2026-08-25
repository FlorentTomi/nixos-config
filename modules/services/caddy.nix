{
  flake.modules.nixos.caddy =
    { ... }:
    {
      services.caddy = {
        enable = true;
        globalConfig = ''
          skip_install_trust
        '';
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
    };
}
