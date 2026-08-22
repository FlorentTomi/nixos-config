# Impermanent root + persisted state, validated against the throwaway
# x86_64 VM prototype (modules/hosts/vm-impermanence-test.nix, since
# deleted) before being ported here. Labels (FIRMWARE/NIX/PERSIST) match
# what Phase 8's sd-image build partitions the SD card into.
{ inputs, ... }:
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  fileSystems."/" = {
    fsType = "tmpfs";
    device = "tmpfs";
    options = [ "size=512M" "mode=755" ];
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIX";
    fsType = "ext4";
  };

  # @persist subvolume — everything else needed across a reboot lives here.
  fileSystems."/persist" = {
    device = "/dev/disk/by-label/PERSIST";
    fsType = "btrfs";
    options = [ "subvol=@persist" "compress=zstd:1" "noatime" ];
    neededForBoot = true;
  };

  # @docker subvolume — kept separate from @persist so Docker's own
  # snapshots/wear don't get bundled with the rest of persisted state.
  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-label/PERSIST";
    fsType = "btrfs";
    options = [ "subvol=@docker" "compress=zstd:1" "noatime" ];
    neededForBoot = true;
  };

  services.journald.storage = "volatile";

  environment.persistence."/persist" = {
    hideMounts = true;
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/var/lib/sops-nix/key.txt"
    ];
    directories = [
      "/var/lib/tailscale"
      "/var/lib/nixos"
    ];
  };
}
