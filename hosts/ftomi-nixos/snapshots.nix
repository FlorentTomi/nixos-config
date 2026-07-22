{ ... }:
{
  services.btrbk.instances.local = {
    onCalendar = "daily";
    snapshotOnly = true;
    settings = {
      snapshot_preserve_min = "2d";
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
