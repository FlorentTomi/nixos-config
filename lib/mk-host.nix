# Builds one nixosConfiguration from a host definition (see ../hosts.nix).
#
# One host = one hardware/identity dir under ./hosts, plus which optional
# Home Manager profiles that user should get on that host. `home/${user}`
# (identity: always-on regardless of host) is imported unconditionally;
# homeProfiles are opt-in extras composed here so the combination is visible
# at the call site instead of buried in a bundle file. Desktop environment
# (niri, stylix, ...) at the NixOS level is each host's own choice, wired
# from its own imports (see modules/niri.nix, profiles/ftomi/stylix.nix).
{
  inputs,
  home-manager,
  sops-nix,
  nix-index-database,
}:
{
  hostname,
  user,
  homeProfiles ? [ ],
  system ? "x86_64-linux",
  # Single source of truth for the base16 scheme name. Consumed by
  # profiles/ftomi/stylix.nix (builds the base16Scheme file path) and by
  # home/profiles/shell.nix (starship preset name) — Stylix only owns
  # *colors*, not a prompt's shape, so the starship preset still has to be
  # picked by name. This just keeps the name from silently drifting between
  # the two. If you switch schemes and no matching starship preset exists,
  # override it locally in shell.nix.
  themeName,
  # Physical disk to install/boot from, as a stable /dev/disk/by-id path.
  # Override per-call (or via `--arg diskDevice ...` / disko-install's own
  # `--disk main <device>` flag) when installing onto different hardware —
  # you should never need to hand-edit disko-config.nix.
  diskDevice,
}:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs diskDevice themeName user; };
  modules = [
    ../hosts/${hostname}
    inputs.disko.nixosModules.disko
    home-manager.nixosModules.home-manager
    sops-nix.nixosModules.sops
    nix-index-database.nixosModules.default
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";
      home-manager.extraSpecialArgs = {
        inherit inputs themeName;
      };
      home-manager.users.${user} = {
        imports = [ ../home/${user} ] ++ map (p: ../home/profiles + "/${p}.nix") homeProfiles;
      };

      nixpkgs.overlays = [
        (final: prev: {
          dashlane-cli = final.callPackage ../pkgs/dashlane-cli.nix { };
        })
      ];
    }
  ];
}
