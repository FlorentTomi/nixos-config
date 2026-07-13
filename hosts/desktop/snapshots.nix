{ ... }:
{
  services.btrbk.instances.local = {
    onCalendar = "hourly";
    snapshotOnly = true;
    settings = {
      snapshot_preserve_min = "2d";
      snapshot_preserve = "14d";
      volume."/" = {
        subvolume."." = {
          snapshot_create = "always";
        };
      };
      volume."/home" = {
        subvolume."." = {
          snapshot_create = "always";
        };
      };
      volume."/var/log" = {
        subvolume."." = {
          snapshot_create = "always";
        };
      };
    };
  };
}
