{ ... }:
{
  # Periodic TRIM instead of inline `discard` mount option — batches the
  # work rather than doing it on every delete, easier on this machine's
  # aging SATA SSD controller than continuous discard would be.
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # Keep an eye on wear/health on an older drive.
  services.smartd = {
    enable = true;
    notifications.wall.enable = true;
  };

  # fileSystems."/mnt/data" = {
  #   device = "/dev/disk/by-uuid/d525a6bb-a97f-4e5f-a0ec-a0eb6b4845f1";
  #   fsType = "xfs";
  #   options = [
  #     "defaults"
  #     "nofail"
  #   ];
  # };
}
