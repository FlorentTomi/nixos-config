{ ... }:
{
  services.btrbk.instances.local = {
    onCalendar = "daily";
    settings = {
      snapshot_preserve_min = "1d";
      snapshot_preserve = "5d 3w";
      volume."/" = {
        subvolume."." = {
          snapshot_create = "onchange";
        };
      };
      volume."/home" = {
        subvolume."." = {
          snapshot_create = "onchange";
        };
      };
      volume."/var/log" = {
        subvolume."." = {
          snapshot_create = "onchange";
        };
      };
    };
  };
}
