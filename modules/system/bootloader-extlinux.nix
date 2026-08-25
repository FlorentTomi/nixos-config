# U-Boot/extlinux boot path for aarch64 boards (e.g. the Pi 3B+) that have
# no EFI firmware. Separate key from `bootloader` (limine/EFI, x86-only) —
# module-registry.nix's lazyAttrsOf merges same-named keys silently instead
# of erroring, so reusing that name would silently combine both configs.
{
  flake.modules.nixos.bootloader-extlinux = {
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
  };
}
