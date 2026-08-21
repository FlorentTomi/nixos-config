{ diskDevice, ... }:
import ../../lib/btrfs-disko-layout.nix {
  inherit diskDevice;
  extraSubvolumes."@games" = {
    mountpoint = "/games";
    mountOptions = [
      "compress=zstd"
      "noatime"
    ];
  };

  extraSubvolumes."@dev" = {
    mountpoint = "/development";
    mountOptions = [
      "compress=zstd"
      "noatime"
    ];
  };
}
