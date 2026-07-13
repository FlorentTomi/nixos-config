{ ... }:
{
  # Local btrfs snapshots as a safety net against mistakes (accidental rm, bad
  # config, etc). Not an offsite/off-machine backup — that needs a separate
  # target (restic repo, external drive) which requires a destination and
  # credentials this file can't invent.
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
