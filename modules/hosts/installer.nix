# Custom, per-host NixOS installer ISOs.
#
# For each host in `config.hosts`, generates:
#   - nixosConfigurations.<host>-base  — minimal install target: hardware,
#     disko, users, boot, networking, and nothing else. This is what
#     actually lands on disk, so the offline install stays small.
#   - nixosConfigurations.installer-<host> — the ISO itself. Ships the
#     `<host>-base` closure plus every flake input's source tree baked
#     into isoImage.storeContents, so evaluation and install both work
#     with zero network, on any physical machine (the disk is chosen
#     interactively at install time, not baked in).
#   - packages.x86_64-linux.iso-<host> — flattens the build command to
#     `nix build .#iso-<host>`.
#
# Post-install, the target boots into <host>-base with a copy of this
# repo already at ~/<user>/nixos-config (baked in via disko-install's
# --extra-files) and a `nixos-post-install` command in PATH to reattach
# real git history and switch to the full <host> config.
{
  config,
  inputs,
  lib,
  ...
}:
let
  # Every flake input's fetched source tree. Baking these onto the ISO,
  # unmodified, is what makes evaluation offline-safe: Nix matches the
  # identical hash-pinned store path already on disk and never re-fetches.
  inputSources = map (i: i.outPath) (lib.attrValues inputs);

  # This whole ISO/disko-install/EFI flow is x86-specific; other-arch hosts
  # (e.g. an aarch64 Pi) opt out and use a different deploy path entirely.
  x86Hosts = lib.filterAttrs (_: v: v.system == "x86_64-linux") config.hosts;

  mkBaseHost =
    hostName:
    let
      hostCfg = config.hosts.${hostName};
    in
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        inherit (hostCfg) user diskDevice;
      };
      modules = [
        config.flake.modules.nixos.base
        ../../hosts/${hostName}/hardware-configuration.nix
        ../../hosts/${hostName}/disko-config.nix
        ../../hosts/${hostName}/users.nix
        ../../hosts/${hostName}/boot.nix
        ../../hosts/${hostName}/networking.nix
        (
          { pkgs, ... }:
          {
            # config.flake.modules.nixos.base declares sops secrets (e.g. the
            # gitlab ssh key) unconditionally, so -base needs the same
            # defaultSopsFile the full host config sets, or eval fails
            # with "sops.defaultSopsFile was accessed but has no value".
            sops.defaultSopsFile = ../../hosts/${hostName}/secrets.yaml;

            environment.systemPackages = [
              pkgs.git
              (pkgs.writeShellScriptBin "nixos-post-install" (
                builtins.readFile ../../resources/nixos-post-install.sh
              ))
            ];
          }
        )
      ];
    };

  mkInstaller =
    hostName:
    let
      hostCfg = config.hosts.${hostName};
    in
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        (
          { pkgs, ... }:
          {
            environment.etc."nixos-config".source = ../..;

            isoImage.storeContents = inputSources ++ [
              config.flake.nixosConfigurations."${hostName}-base".config.system.build.toplevel
            ];

            environment.systemPackages = [
              inputs.disko.packages.x86_64-linux.disko-install
              (pkgs.writeShellScriptBin "install-${hostName}" ''
                set -euo pipefail
                echo "== Installing ${hostName} (minimal base, offline) =="
                echo

                mapfile -t DISKS < <(find /dev/disk/by-id -maxdepth 1 -type l | sort)
                [ ''${#DISKS[@]} -gt 0 ] || { echo "No disks found under /dev/disk/by-id" >&2; exit 1; }

                PS3="Select target disk (THIS WILL BE WIPED): "
                select DISK in "''${DISKS[@]}"; do
                  [ -n "''${DISK:-}" ] && break
                done

                echo
                lsblk "$DISK" || true
                echo
                read -p "Type 'yes' to wipe $DISK and install ${hostName}: " confirm
                [ "$confirm" = "yes" ] || { echo "Aborted."; exit 1; }

                EXTRA_FILES=(
                  --extra-files /etc/nixos-config /home/${hostCfg.user}/nixos-config
                )
                read -p "Path to sops age key to copy in (blank to skip): " keypath
                if [ -n "''${keypath:-}" ] && [ -f "$keypath" ]; then
                  EXTRA_FILES+=(--extra-files "$keypath" /var/lib/sops-nix/key.txt)
                fi

                disko-install \
                  --flake /etc/nixos-config#${hostName}-base \
                  --disk main "$DISK" \
                  --write-efi-boot-entries \
                  --option substituters "" \
                  "''${EXTRA_FILES[@]}"

                echo
                echo "Done. Reboot, then log in as ${hostCfg.user} and run:"
                echo "  nixos-post-install"
              '')
            ];
          }
        )
      ];
    };
in
{
  flake.nixosConfigurations = lib.mkMerge [
    (lib.mapAttrs' (h: _: lib.nameValuePair "${h}-base" (mkBaseHost h)) x86Hosts)
    (lib.mapAttrs' (h: _: lib.nameValuePair "installer-${h}" (mkInstaller h)) x86Hosts)
  ];

  flake.packages.x86_64-linux = lib.mapAttrs' (
    h: _:
    lib.nameValuePair "iso-${h}"
      config.flake.nixosConfigurations."installer-${h}".config.system.build.isoImage
  ) x86Hosts;
}
