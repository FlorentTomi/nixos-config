# Hand-written (cross-compiled, no hardware scan). Deliberately minimal:
# mainline aarch64 kernels build MMC/SD-card support directly into the
# kernel image (not as a loadable module), since you need it before any
# module could be loaded from disk — so no availableKernelModules entry is
# expected here. sd-image.nix (Phase 8) supplies whatever else the SD-card
# boot path itself needs. Revisit if Phase 8/9 testing says otherwise.
{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];
}
