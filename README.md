# nixos-config

NixOS + Home Manager flake for `ftomi`'s desktop — AMD 5800X, RTX 3060 (open
kernel module), Niri (structured config via niri-flake, not raw KDL),
Catppuccin theming, SDDM login, Steam/gaming.

## Layout — dendritic pattern

Every `.nix` file under `modules/` (except `modules/module-registry.nix`
itself) is a [flake-parts](https://flake.parts) module, auto-discovered by
[`import-tree`](https://github.com/vic/import-tree) — no manual
`default.nix` bundlers, no import lists to keep in sync. One file
implements one feature, across every configuration class (NixOS,
home-manager) that feature touches — e.g. `modules/niri.nix` sets both
`nixos.modules.niri` (compositor enable, portal, polkit agent) and
`homeManager.modules.niri` (keybinds, layout) in the same file, instead of
splitting across a `hosts/`/`home/` boundary.

- `modules/module-registry.nix` — declares the option namespace every other
  module writes into:
  - `nixos.modules.<name>` / `homeManager.modules.<name>` — each a
    `lazyAttrsOf deferredModule`. **Importing a name is what enables it** —
    there are no `enable` options on our own modules (unlike upstream
    options like `programs.niri.enable`, which stay exactly as niri-flake
    defines them).
  - `hosts.<name>` — per-host data (`user`, `diskDevice`), read back by that
    host's own module instead of threading `specialArgs` by hand.
- `modules/<feature>.nix` — flat, one file per feature
  (`waybar.nix`, `audio.nix`, `git.nix`, `nvidia.nix`, ...). Genuinely
  parametrized per-host data (not just an on/off gate) lives under
  `custom.<name>.*`, e.g. `custom.openvpn.configs`, `custom.console.backend`
  — distinct from real nixpkgs options and from the old
  `options.modules.<name>.enable` pattern this replaced.
- `modules/roles/<name>.nix` — a role is a module whose body is *only*
  `imports`, composing other named modules (e.g.
  `roles/gaming-desktop.nix` = steam + gamemode + sunshine + ... on both the
  nixos and home-manager sides). This is what makes adding a host cheap:
  import 1-2 role names instead of re-deriving which of ~50 files apply.
  `roles/base.nix` is what every host gets — core infra (disko/sops-nix/
  nix-index-database/home-manager unlocks, dconf, networking, tailscale,
  bootloader, ...).
- `modules/hosts/<name>.nix` — the host-producing module. Sets
  `hosts.<name>` (user, diskDevice) and `flake.nixosConfigurations.<name>`,
  pulling in `config.nixos.modules.*`/`config.homeManager.modules.*` by
  name plus this machine's raw hardware/identity files.
- `hosts/<name>/` — **only** files that can't be anything but this exact
  machine: `hardware-configuration.nix`, `disko-config.nix`,
  `secrets.yaml`, and genuinely one-off hardware quirks
  (`bluetooth.nix`, `smartd.nix`, `monitors.nix`, ...). Referenced by
  direct path from `modules/hosts/<name>.nix`, never through the registry.
- `resources/` — non-Nix assets (CSS, shell scripts, yuck widgets) consumed
  by modules via `import`/`readFile`. Deliberately **outside** `modules/` —
  `import-tree` scans every `.nix` file under `modules/` as a flake-parts
  module, so plain data/helper `.nix` files (not modules) live here instead
  to avoid being auto-imported and evaluated as one.
- `lib/btrfs-disko-layout.nix` — reusable disko btrfs partition/subvolume
  layout generator, unchanged in shape from before the migration.

Adding a program is one new `modules/<name>.nix` file — no `default.nix` to
edit, no import list to update. It becomes available the moment
`import-tree` picks it up; a host (or role) opts in by naming it in its
`imports`.

## First install (new machine)

Disk layout (partitions, btrfs subvolumes `@`, `@home`, `@nix`, `@log`,
`@games`) is declared once in `hosts/<name>/disko-config.nix` and driven by
[disko](https://github.com/nix-community/disko). You should never need to
manually `mkfs`, `btrfs subvolume create`, or hand-edit `fileSystems`.

1. Boot the NixOS minimal ISO on the target machine.
2. Find the target disk's stable identifier (never use `/dev/sda`-style
   names, they aren't guaranteed stable):
   ```bash
   ls -l /dev/disk/by-id/
   ```
3. Run `disko-install`, pointing `--disk main` at that path. This partitions,
   formats, mounts, and installs in one step:
   ```bash
   sudo nix run github:nix-community/disko/latest#disko-install -- \
     --flake github:FlorentTomi/nixos-config#ftomi-nixos \
     --disk main /dev/disk/by-id/<target-disk-id> \
     --write-efi-boot-entries
   ```
   The `--disk main <device>` flag overrides the disk path for this install
   **without editing the repo first** — that's what makes the config
   portable across physical disks/machines.
4. Reboot into the new system.
5. **After confirming it boots correctly**, update the default disk path so
   future `nixos-rebuild switch` runs (which don't go through
   `disko-install`, so don't get the `--disk` override) use the right device
   too — edit `diskDevice` for this host in `modules/hosts/<name>.nix`:
   ```nix
   hosts.ftomi-nixos = {
     user = "ftomi";
     diskDevice = "/dev/disk/by-id/<the-disk-you-actually-installed-on>";
   };
   ```
   Commit that change. Only needed if the disk differs from what's already
   set — reinstalling onto the *same* physical disk needs no edit.

Two things disko can't cover, still need doing by hand on first install of
*any* new host:

- **`hardware-configuration.nix`'s non-filesystem parts** (kernel modules,
  CPU microcode) — generate with filesystems excluded, since disko already
  provides those:
  ```bash
  sudo nixos-generate-config --no-filesystems --root /mnt
  ```
- **sops-nix age key** — must be present on the new machine before secrets
  decrypt (`/var/lib/sops-nix/key.txt`); copy it over or generate a new one
  and re-encrypt secrets for this host's key.

## Adding a subvolume to an already-installed host

`disko-config.nix` is only applied at install time by `disko-install` — on
an existing machine, adding an entry to `extraSubvolumes` teaches the disko
NixOS module to generate a `fileSystems` mount for it, but the subvolume
itself must exist on disk already, or the mount fails. Create it by hand
first:

1. Add the entry to `hosts/<name>/disko-config.nix`, e.g.:
   ```nix
   extraSubvolumes."@dev" = {
     mountpoint = "/development";
     mountOptions = [ "compress=zstd" "noatime" ];
   };
   ```
2. Find the root btrfs partition (`findmnt -no SOURCE /`, e.g. `/dev/sda2`).
3. Mount the top-level subvolume (id 5) and create the new one under it:
   ```bash
   sudo mount -o subvolid=5 /dev/sda2 /mnt
   sudo btrfs subvolume create /mnt/@dev
   sudo umount /mnt
   ```
4. Rebuild — this generates and mounts the new `fileSystems` entry:
   ```bash
   nh os switch
   ```

## Subsequent builds / switches

This config uses [`nh`](https://github.com/nix-community/nh) (`programs.nh`,
`modules/core-nix.nix`) instead of raw `nixos-rebuild` — nicer diff/output
via `nix-output-monitor`, and `NH_FLAKE` is already pointed at this repo so
no `--flake .#hostname` needed. `nh` finds `sudo` itself; don't prefix it.

```bash
cd ~/nixos-config
# edit whatever you need
nh os switch
```

No reboot needed *except* for: kernel changes, bootloader changes,
display/GPU driver changes, or display-manager swaps. Everything else
(packages, niri config, waybar, dotfiles, services) applies live.

### Try before committing

```bash
nh os test
```

Applies for this session only. Reboot reverts cleanly to the last `switch`ed
generation if something's broken — nothing is made permanent until you
`nh os switch` (or `nh os boot`, which sets the boot default without
activating now).

### Rollback

```bash
nh os rollback              # previous generation
nh os rollback --to <N>     # a specific one
```

Or pick an older generation directly from the Limine boot menu at boot.

### List generations

```bash
nh os info
```

## Updates

Update every flake input (nixpkgs, home-manager, niri, walker, ...)
and switch in one go:

```bash
nh os switch --update
```

Update just one input instead:

```bash
nh os switch --update-input nixpkgs
```

Either way, review `flake.lock`'s diff (`git diff flake.lock`) before
trusting the result, and commit it once you've confirmed the new generation
boots and works. `--update`/`--update-input` also work with `nh os
test`/`build` if you want to check before committing to a switch.

### Garbage collection

`modules/core-nix.nix` already runs `nh clean` daily (`--keep 5
--keep-since 2d`), so old generations get pruned automatically. To do it
manually right now instead:

```bash
nh clean all --keep 5 --keep-since 2d
```

## Finding a package to add

```bash
nix search nixpkgs <name>
```

Or browse https://search.nixos.org/packages — and check
https://search.nixos.org/options first for a structured `programs.<name>` /
`services.<name>` module before just dropping it in `home.packages` /
`environment.systemPackages`.

### Try a package once, without adding it to config

```bash
nix shell nixpkgs#<name>
```

## Adding a new host

1. **Generate the hardware facts** (filesystems excluded — disko supplies
   those via `disko-config.nix`):
   ```bash
   sudo nixos-generate-config --no-filesystems --show-hardware-config > hosts/<name>/hardware-configuration.nix
   ```
2. **Write `hosts/<name>/disko-config.nix`** describing the disk layout
   (copy `hosts/ftomi-nixos/disko-config.nix` as a starting point).
3. **Create `modules/hosts/<name>.nix`**, modeled on
   `modules/hosts/ftomi-nixos.nix`:
   - set `hosts.<name> = { user = "..."; diskDevice = "..."; };`
   - build `flake.nixosConfigurations.<name>` via `nixpkgs.lib.nixosSystem`,
     pulling in `config.nixos.modules.base` plus whichever role(s)
     (`config.nixos.modules.gaming-desktop`, or a new
     `modules/roles/laptop.nix` once one exists) and any individual
     `config.nixos.modules.<name>` toggles this machine needs
   - list `./hardware-configuration.nix`, `./disko-config.nix`, and any
     genuinely host-only raw files (kernel/boot tuning, networking
     hostname, monitor topology, etc. — anything that's actually a trait of
     a role rather than this one machine belongs in `modules/roles/`
     instead)
   - set `system.stateVersion` to whatever release was current when the
     host was first installed — **never change this retroactively**
   - list the home-manager modules this host/user wants under
     `home-manager.users.<user>.imports`, pulling from
     `config.homeManager.modules.*` the same way
4. Rebuild with `nh os switch --hostname <name>` (or `-H <name>`) — needed
   the first time since `NH_FLAKE`'s default hostname resolution won't yet
   match on a machine that isn't `<name>` itself.

`hardware-configuration.nix`, `disko-config.nix`, `diskDevice`, and any
other genuinely machine-specific file should never be shared between
hosts — everything under `modules/` (leaf features and roles alike) is
written to be reused.
