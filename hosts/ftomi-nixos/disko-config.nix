{ ... }:
{
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_M.2_250GB_S33CNX0H801497R"; # stable across reboots/hw changes, unlike /dev/sda
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0022" "dmask=0022" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                };
                "@home" = {
                  mountpoint = "/home";
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "noatime" ];
                };
                "@log" = {
                  mountpoint = "/var/log";
                };
                "@games" = {
                  mountpoint = "/games";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
