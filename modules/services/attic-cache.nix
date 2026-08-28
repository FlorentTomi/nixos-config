{
  flake.modules.nixos.attic-cache =
    { config, lib, ... }:
    {
      users.users.atticd = {
        isSystemUser = true;
        group = "atticd";
      };

      users.groups.atticd = { };

      systemd.services.atticd.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = lib.mkForce "atticd";
        Group = lib.mkForce "atticd";
      };

      services.postgresql = {
        enable = true;
        ensureDatabases = [ "atticd" ];
        ensureUsers = [
          {
            name = "atticd";
            ensureDBOwnership = true;
          }
        ];
      };

      services.atticd = {
        enable = true;
        environmentFile = config.sops.secrets.attic-env.path;
        settings = {
          listen = "0.0.0.0:8080";
          database.url = "postgresql:///atticd?host=/run/postgresql&user=atticd";
          storage = {
            type = "s3";
            region = "eu-central-003";
            bucket = "ftomi-nix-cache";
            endpoint = "https://s3.eu-central-003.backblazeb2.com";
          };
        };
      };

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8080 ];

      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      sops.age.keyFile = lib.mkForce null;
      sops.secrets.attic-env = {
        sopsFile = ../../hosts/ftomi-rpi/secrets.yaml;
      };
    };
}
