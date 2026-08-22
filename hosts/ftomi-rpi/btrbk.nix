# Host-local, not config.nixos.modules.btrbk: that shared module targets
# volume."/" / "/home" / "/var/log", none of which are btrfs on this host
# (root is tmpfs). Only /persist is snapshotted — /var/lib/docker is left
# out to avoid snapshot bloat from container layers.
{
  services.btrbk.instances.local = {
    onCalendar = "daily";
    settings = {
      snapshot_preserve_min = "1d";
      snapshot_preserve = "5d 3w";
      volume."/persist" = {
        subvolume."." = {
          snapshot_create = "onchange";
        };
      };
    };
  };
}
