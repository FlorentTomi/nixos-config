# Impermanence, single-real-partition style: one persistent partition
# (built by sd-image.nix, labeled NIXOS_SD, mounted at /state) holds
# /nix and /boot — baked in at image-build time — plus whatever
# accumulates under /state/persist at runtime. "/" itself is tmpfs, wiped
# every boot; only paths explicitly bind-mounted or listed below survive.
{ inputs, ... }:
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  fileSystems = {
    "/state" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      neededForBoot = true;
    };

    "/nix" = {
      device = "/state/nix";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
    };

    "/boot" = {
      device = "/state/boot";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
    };
  };

  services.journald.storage = "volatile";

  environment.persistence."/state/persist" = {
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
      "/var/lib/docker"
      "/var/lib/docker-data"
    ];
  };
}
