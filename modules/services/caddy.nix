{
  flake.modules.nixos.caddy = _: {
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
