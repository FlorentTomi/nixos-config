# nixos-config

NixOS + Home Manager flake for `ftomi`'s desktop — AMD 5800X, RTX 3060 (open
kernel module), Niri (structured config via niri-flake, not raw KDL), Stylix
theming, SDDM login (qylock theme), Steam/gaming.

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
# Weekly automatic cleanup already configured (nix.gc in common/nix.nix),
# keeps 14 days of generations. To do it manually right now instead:
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

## Adding a new host

Each host is one hardware/identity directory under `./hosts`, wired up by the
`mkHost` function in `flake.nix`. Everything else — Stylix, Niri, Home Manager
plumbing, overlays — is shared automatically.

1. **Generate the hardware facts:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/<name>/hardware-configuration.nix
   ```
2. **Create `hosts/<name>/default.nix`**, modeled on `hosts/ftomi-nixos/default.nix`:
   - import the `common/*.nix` modules you want (most hosts want all of them)
   - import a `profiles/<person>/*.nix` set for personal preferences (locale,
     Stylix theme, login theme) — reuse `profiles/ftomi` or add a new one
   - import any `modules/*.nix` toggles this machine needs (e.g.
     `modules/nvidia.nix`) and set the corresponding `modules.<name>.enable`
   - import `./hardware-configuration.nix` plus any host-only files
     (kernel/boot tuning, storage, networking hostname, etc.)
   - set `system.stateVersion` to whatever release was current when the host
     was first installed — **never change this retroactively**
3. **Register it in `flake.nix`:**
   ```nix
   nixosConfigurations.<name> = mkHost { hostname = "<name>"; };
   ```
   Pass `homeProfile = ./home/profiles/<profile>.nix` to `mkHost` if this host
   shouldn't use the default `desktop` Home Manager profile.
4. Rebuild with `sudo nixos-rebuild switch --flake .#<name>`.

`hardware-configuration.nix` and any other genuinely machine-specific file
(disk UUIDs, hostname) should never be shared between hosts — everything else
under `common/`, `profiles/`, and `modules/` is written to be reused.
