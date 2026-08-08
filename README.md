# nixos-config

NixOS + Home Manager flake for `ftomi`'s desktop — AMD 5800X, RTX 3060 (open
kernel module), Niri (structured config via niri-flake, not raw KDL), Stylix
theming, Ly login, Steam/gaming.

## Day-to-day

```bash
cd ~/nixos-config
# edit whatever you need
sudo nixos-rebuild switch --flake .#ftomi-nixos
```

No reboot needed *except* for: kernel changes, bootloader changes, display/GPU
driver changes, or display-manager swaps. Everything else (packages, niri config,
waybar, dotfiles, services) applies live.

## Try before committing

```bash
sudo nixos-rebuild test --flake .#ftomi-nixos
```

Applies for this session only. Reboot reverts cleanly to the last `switch`ed
generation if something's broken — nothing is made permanent until you `switch`.

## Rollback

```bash
sudo nixos-rebuild switch --rollback
```

Or pick an older generation directly from the Limine boot menu at boot.

## List generations

```bash
nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Garbage collection

```bash
# Daily automatic cleanup already configured (nix.gc in hosts/base/nix.nix),
# deletes generations older than 2 days. To do it manually right now instead:
sudo nix-collect-garbage -d      # deletes ALL old generations, keeps only current
```

## Finding a package to add

```bash
nix search nixpkgs 
```
Or browse https://search.nixos.org/packages — and check
https://search.nixos.org/options first for a structured `programs.<name>` /
`services.<name>` module before just dropping it in `home.packages` /
`environment.systemPackages`.

## Try a package once, without adding it to config

```bash
nix shell nixpkgs#
```

## Installing on new hardware

Disk layout (partitions, btrfs subvolumes `@`, `@home`, `@nix`, `@log`,
`@games`) is declared once in `hosts/<name>/disko-config.nix` and driven by
[disko](https://github.com/nix-community/disko). You should never need to
manually `mkfs`, `btrfs subvolume create`, or hand-edit `fileSystems` again —
disko generates all of that from the flake.

### Fresh install (recommended: `disko-install`)

1. Boot the NixOS minimal ISO on the target machine.
2. Find the target disk's stable identifier (never use `/dev/sda`-style
   names, they aren't guaranteed stable):
   ```bash
   ls -l /dev/disk/by-id/
   ```
3. Run `disko-install`, pointing `--disk main` at that path. This partitions,
   formats, mounts, and installs in one step — no manual partitioning, no
   `nixos-generate-config` for filesystems:
   ```bash
   sudo nix run github:nix-community/disko/latest#disko-install -- \
     --flake github:FlorentTomi/nixos-config#ftomi-nixos \
     --disk main /dev/disk/by-id/<target-disk-id> \
     --write-efi-boot-entries
   ```
   The `--disk main <device>` flag overrides the disk path for this install
   **without needing to edit any file in the repo first** — this is what
   makes the config portable across different physical disks/machines.
4. Reboot into the new system.
5. **After confirming it boots correctly**, update the default disk path so
   future `nixos-rebuild switch` runs (which don't go through
   `disko-install`, so don't get the `--disk` override) use the right device
   too — edit `diskDevice` for this host in `flake.nix`:
   ```nix
   nixosConfigurations.ftomi-nixos = mkHost {
     # ...
     diskDevice = "/dev/disk/by-id/<the-disk-you-actually-installed-on>";
   };
   ```
   Commit that change. This step only matters if the disk differs from
   what's already set — reinstalling onto the *same* physical disk needs no
   edit at all.

### Adding a brand new host

If you're setting up a different machine (not replacing this one's disk),
copy `hosts/ftomi-nixos/disko-config.nix` into the new host's directory,
adjust subvolume names/mountpoints if needed, and give it its own
`diskDevice` when registering it in `flake.nix` (see step below). Each host
gets its own disk identity — never share a `diskDevice` value between two
different machines.

### What's still genuinely per-machine

Disko covers disk layout, but two things still need generating/checking on
first install of *any* new host, since they depend on physical hardware
disko doesn't know about:

- **`hardware-configuration.nix`'s non-filesystem parts** (kernel modules,
  CPU microcode) — generate with filesystems excluded, since disko already
  provides those:
  ```bash
  sudo nixos-generate-config --no-filesystems --root /mnt
  ```
- **sops-nix age/GPG key** — must be present on the new machine before
  secrets will decrypt; this is unrelated to disko and has to be bootstrapped
  separately (copy the key, or generate + re-encrypt secrets for the new
  host's key).

## Adding a new host

Each host is one hardware/identity directory under `./hosts`, wired up by the
`mkHost` function in `flake.nix`. Everything else — Stylix, Niri, Home Manager
plumbing, overlays — is shared automatically.

1. **Generate the hardware facts** (filesystems excluded — disko supplies
   those via `disko-config.nix`, see "Installing on new hardware" above):
   ```bash
   sudo nixos-generate-config --no-filesystems --show-hardware-config > hosts/<name>/hardware-configuration.nix
   ```
1b. **Write `hosts/<name>/disko-config.nix`** describing the disk layout for
   this host (copy `hosts/ftomi-nixos/disko-config.nix` as a starting point).
2. **Create `hosts/<name>/default.nix`**, modeled on `hosts/ftomi-nixos/default.nix`:
   - import the `common/*.nix` modules you want (most hosts want all of them)
   - import a `profiles/<person>/*.nix` set for personal preferences (locale,
     Stylix theme, login theme) — reuse `profiles/ftomi` or add a new one
   - import any `modules/*.nix` toggles this machine needs (e.g.
     `modules/nvidia.nix`) and set the corresponding `modules.<name>.enable`
   - import `./hardware-configuration.nix`, `./disko-config.nix`, plus any
     host-only files (kernel/boot tuning, networking hostname, etc.)
   - set `system.stateVersion` to whatever release was current when the host
     was first installed — **never change this retroactively**
3. **Register it in `flake.nix`**, including its `diskDevice` (see
   "Installing on new hardware" above for finding this):
   ```nix
   nixosConfigurations.<name> = mkHost {
     hostname = "<name>";
     user = "<name>";
     homeProfile = "<profile>";
     diskDevice = "/dev/disk/by-id/<this-host's-disk>";
   };
   ```
4. Rebuild with `sudo nixos-rebuild switch --flake .#<name>`.

`hardware-configuration.nix`, `disko-config.nix`'s referenced `diskDevice`,
and any other genuinely machine-specific file (hostname, etc.) should never
be shared between hosts — everything else under `common/`, `profiles/`, and
`modules/` is written to be reused.
