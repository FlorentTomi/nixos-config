{ ... }:
{
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/d525a6bb-a97f-4e5f-a0ec-a0eb6b4845f1";
    fsType = "xfs";
    options = [
      "defaults"
      "nofail"
    ];
  };
}
