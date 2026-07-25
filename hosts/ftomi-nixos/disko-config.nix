{ diskDevice, ... }:
{
  disko.devices = {
    disk.main = {
      device = diskDevice; # set per-host in flake.nix (mkHost's diskDevice arg),
      # or overridden ad hoc at install time via `disko-install --disk main <device>`
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
