# Minimal role for headless aarch64 boards (e.g. the Pi 3B+). Deliberately
# does not import config.flake.modules.nixos.base: that role pulls in limine/EFI
# bootloader, an ESP-based disko layout, audio/dconf/xdg-portal, and a
# home-manager+dashlane overlay — all x86/GUI-desktop-shaped and irrelevant
# (or actively wrong) here. Reuses only the arch-agnostic pieces of base,
# swapping bootloader for bootloader-extlinux.
{
  config,
  inputs,
  ...
}:
{
  flake.modules.nixos.headless-arm.imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.nix-index-database.nixosModules.default
  ]
  ++ (with config.flake.modules.nixos; [
    core-nix
    zram
    tailscale
    secrets
    bootloader-extlinux
    oomd
    locale
  ]);
}
