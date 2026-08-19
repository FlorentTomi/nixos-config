# nixos-config

NixOS + Home Manager flake for `ftomi`'s desktop — AMD 5800X, RTX 3060 (open
kernel module), Niri (structured config via niri-flake, not raw KDL),
Catppuccin theming, SDDM login, Steam/gaming.

## Layout

- `home/<user>/` — home-manager **identity**: the genuinely minimal, portable
  base — always on for that user, regardless of host. Nix tooling (`nil.nix`,
  `nixd.nix`), a minimal Niri setup (`niri.nix`, un-themed by default), a base
  shell (`fish.nix`, `ghostty.nix`), one browser (`floorp.nix`), and the bare
  minimum to edit this repo (`git.nix`, `zed.nix`).
- `home/profiles/` — home-manager **opt-in** pieces a host can pick from.
  Single-program profiles are a flat `program-name.nix`; anything that
  bundles several programs sharing one intent is a directory (`shell/`,
  `session/`, `gaming/`, `hobbies/`, `dev-tools/`, `design/`, `office/`) with
  a `default.nix` that imports the split-out files, so it's still one path
  to import. `theme.nix` lives here too (Catppuccin) — `niri.nix` in the base
  identity works with or without it, so a host only gets themed once it
  explicitly imports `home/profiles/theme.nix`.
- `hosts/base/` — NixOS config shared by every host, one file per subsystem
  (`pipewire.nix`, `tailscale.nix`, `bootloader.nix`, ...).
- `hosts/profiles/` — NixOS **archetype** bundles a host opts into as a
  whole, mirroring the home-manager base/profiles split at the system level.
  `sddm.nix` is a flat single-choice profile (display manager); directories
  like `gaming-desktop/` bundle every trait that only makes sense together
  (Steam, gamemode, Sunshine streaming, fan/pump control, VIA keyboard
  flashing, wifi tuned for a wired desktop) behind one `default.nix` import.
  `laptop/` exists as a scaffold for the same pattern, filled in once a real
  laptop host validates what it actually needs.
- `hosts/<name>/` — one machine, kept thin: `default.nix` wires together
  `base/`, `modules/`, whichever `hosts/profiles/*` archetype(s) this machine
  is, this machine's own genuinely-unique files (hardware quirks like
  `bluetooth.nix`/`smartd.nix`, `hardware-configuration.nix`,
  `disko-config.nix`), and `users.nix`/`networking.nix` (hostname only —
  archetype-level traits live in `hosts/profiles/`, not here). `home.nix`
  lists exactly the `home/profiles/*` this host wants — the single
  home-manager entrypoint.
- `modules/` — toggleable NixOS subsystems with their own
  `options.modules.<name>.enable` (nvidia, niri, openvpn, virtualisation,
  console, ollama).
- `profiles/<person>/` — personal preferences that aren't host-specific
  (locale, keyboard layout).
- `lib/mk-host.nix` — builds one `nixosConfiguration` from a host definition
  in `hosts.nix`.

Adding a program to this user's identity, or to an opt-in profile, is one new
`program-name.nix` file plus one line in the relevant `default.nix`. Adding a
new host archetype trait works the same way one level up, in
`hosts/profiles/`.

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
   too — edit `diskDevice` for this host in `hosts.nix`:
   ```nix
   ftomi-nixos = mkHost {
     # ...
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

## Subsequent builds / switches

This config uses [`nh`](https://github.com/nix-community/nh) (`programs.nh`,
`hosts/base/nix.nix`) instead of raw `nixos-rebuild` — nicer diff/output via
`nix-output-monitor`, and `NH_FLAKE` is already pointed at this repo so no
`--flake .#hostname` needed. `nh` finds `sudo` itself; don't prefix it.

```bash
cd ~/nixos-config
# edit whatever you need
nh os switch                # or: ./nixos-switch.sh
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

Update every flake input (nixpkgs, home-manager, niri, walker, nixvim, ...)
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

`hosts/base/nix.nix` already runs `nh clean` daily (`--keep 5 --keep-since
2d`), so old generations get pruned automatically. To do it manually right
now instead:

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
3. **Create `hosts/<name>/default.nix`**, modeled on
   `hosts/ftomi-nixos/default.nix`:
   - import the `hosts/base/*.nix` files you want (most hosts want all of
     them)
   - import a `profiles/<person>/*.nix` set for personal preferences (reuse
     `profiles/ftomi` or add a new one)
   - import the `hosts/profiles/<archetype>` (e.g. `gaming-desktop/`,
     `laptop/`) that matches what this machine is, plus a display-manager
     choice (`hosts/profiles/sddm.nix` or similar) — this is what makes
     adding a host mostly "pick bundles" instead of re-deriving config from
     scratch
   - import any `modules/*.nix` toggles this machine needs (e.g.
     `modules/nvidia.nix`) and set the corresponding `modules.<name>.enable`
   - import `./hardware-configuration.nix`, `./disko-config.nix`, plus any
     genuinely host-only files (kernel/boot tuning, networking hostname,
     etc. — anything that's actually a trait of the archetype, not this one
     machine, belongs in `hosts/profiles/` instead)
   - set `system.stateVersion` to whatever release was current when the host
     was first installed — **never change this retroactively**
4. **Create `hosts/<name>/home.nix`** listing the `home/profiles/*` this
   host should get (see any existing `hosts/*/home.nix` for the pattern).
5. **Register it in `hosts.nix`**, including its `diskDevice` (see "First
   install" above for finding this):
   ```nix
   <name> = mkHost {
     hostname = "<name>";
     user = "<user>";
     diskDevice = "/dev/disk/by-id/<this-host's-disk>";
   };
   ```
6. Rebuild with `nh os switch --hostname <name>` (or `-H <name>`) — needed
   the first time since `NH_FLAKE`'s default hostname resolution won't yet
   match on a machine that isn't `<name>` itself.

`hardware-configuration.nix`, `disko-config.nix`, `diskDevice`, and any other
genuinely machine-specific file (hostname, etc.) should never be shared
between hosts — everything under `hosts/base/`, `home/`, `profiles/`, and
`modules/` is written to be reused.
