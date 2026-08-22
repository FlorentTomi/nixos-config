# Reuses nixpkgs' own, proven single-partition Pi image pipeline as-is
# (firmware/DTB/U-Boot handling, boot.kernelParams, the whole
# system.build.sdImage assembly) instead of hand-rolling partitioning —
# far less custom code to get subtly wrong. The one thing overridden:
# fileSystems."/" is forced to tmpfs (see filesystems.nix for the rest of
# the impermanence wiring, which repoints stock's single "root" partition
# at /state instead of /).
{ lib, pkgs, inputs, ... }:
{
  imports = [ "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" ];

  # Irrelevant here (no ZFS on this host) — just silences a warning pulled
  # in via all-hardware.nix (part of the imported sd-image chain).
  boot.zfs.forceImportRoot = false;

  sdImage.rootVolumeLabel = "NIXOS_SD";
  # Baked into the image at the root partition's own filesystem root — since
  # that partition is now mounted at /state instead of /, this file shows up
  # at /state/nix-path-registration, not /nix-path-registration. See this
  # option's own docs: "If overriding fileSystems./ then you should set this
  # to the root mount + /nix-path-registration".
  sdImage.nixPathRegistrationFile = "/state/nix-path-registration";

  fileSystems."/" = lib.mkForce {
    fsType = "tmpfs";
    device = "tmpfs";
    options = [
      "size=512M"
      "mode=755"
    ];
  };

  # Stock's own expand-root-partition service hardcodes `findmnt ... /` to
  # find the device to grow — repointed at /state, the only thing that
  # changed now that "/" isn't a real device. Also: derive the partition
  # number from the device name directly (`grep -oE` on the trailing
  # digits) instead of `lsblk -npo PARTN`, which came back empty on real
  # hardware here — likely an MMC-specific early-boot udev timing quirk
  # (sysfs partition metadata not settled yet under sysinit.target); worked
  # fine for a plain SATA/NVMe disk when tested locally.
  systemd.services.expand-root-partition.script = lib.mkForce ''
    rootPart=$(${lib.getExe' pkgs.util-linux "findmnt"} -n -o SOURCE /state)
    bootDevice=$(${lib.getExe' pkgs.util-linux "lsblk"} -npo PKNAME $rootPart)
    partNum=$(echo "$rootPart" | grep -oE '[0-9]+$')

    echo ",+," | ${lib.getExe' pkgs.util-linux "sfdisk"} -N$partNum --no-reread $bootDevice
    ${lib.getExe' pkgs.parted "partprobe"}
    ${lib.getExe' pkgs.e2fsprogs "resize2fs"} $rootPart
  '';
}
