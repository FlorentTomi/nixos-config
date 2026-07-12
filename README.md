# nixos-config

NixOS + Home Manager flake for `ftomi`'s desktop — i5-6600, RTX 3060 (open kernel
module), Niri (raw KDL, no niri-nix), Stylix theming, Ly login, Steam/gaming.

## Day-to-day

```bash
cd ~/nixos-config
# edit whatever you need
sudo nixos-rebuild switch --flake .#desktop
```

No reboot needed *except* for: kernel changes, bootloader changes, display/GPU
driver changes, or display-manager swaps. Everything else (packages, niri config,
waybar, dotfiles, services) applies live.

## Try before committing

```bash
sudo nixos-rebuild test --flake .#desktop
```

Applies for this session only. Reboot reverts cleanly to the last `switch`ed
generation if something's broken — nothing is made permanent until you `switch`.

## Rollback

```bash
sudo nixos-rebuild switch --rollback
```

Or pick an older generation directly from the systemd-boot menu at boot.

## List generations

```bash
nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Garbage collection

```bash
# Weekly automatic cleanup already configured (nix.gc in hosts/desktop/default.nix),
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
