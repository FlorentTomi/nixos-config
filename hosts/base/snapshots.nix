{ ... }:
{
  services.btrbk.instances.local = {
    onCalendar = "daily";
    snapshotOnly = true;
    settings = {
      snapshot_preserve_min = "2d";
      snapshot_preserve = "14d 8w 6m";
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
