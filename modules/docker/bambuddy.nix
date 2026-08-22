{
  nixos.modules.bambuddy =
    { ... }:
    {
      virtualisation.oci-containers.containers.bambuddy = {
        image = "ghcr.io/maziggy/bambuddy:1.2.5.3";

        extraOptions = [
          "--network=host"
        ];

        volumes = [
          "/var/lib/docker-data/bambuddy/data:/app/data"
          "/var/lib/docker-data/bambuddy/logs:/app/logs"
        ];

        environment = {
          TZ = "Europe/Paris";
          PUID = "1000";
          PGID = "1000";
        };
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/docker-data/bambuddy/data 0755 1000 1000 -"
        "d /var/lib/docker-data/bambuddy/logs 0755 1000 1000 -"
      ];
    };
}
