# Builds one nixosConfiguration from a host definition (see ../hosts.nix).
#
# One host = one hardware/identity dir under ./hosts. `home/${user}`
# (identity: always-on regardless of host) is imported unconditionally;
# `hosts/${hostname}/home.nix` is that host's own list of opt-in
# home-manager profiles — a single, self-contained entrypoint instead of a
# string-list stitched together here. Desktop environment
# (niri, ...) at the NixOS level is each host's own choice, wired from its
# own imports (see modules/niri.nix). Theming (Catppuccin, via
# home/ftomi/theme.nix) is scoped entirely to the user's home-manager
# config — nothing at the NixOS/host level needs to know about it.
{
  inputs,
  home-manager,
  sops-nix,
  nix-index-database,
  # Attrset of dendritic flake modules: { nixos.<name> = ...; homeManager.<name> = ...; }
  # Threaded through as a specialArg so host/home files can pull in a named
  # dendrite (e.g. `flakeModules.nixos.khal`) instead of a hand-written
  # relative path — this is the bridge between the old modules/ and home/
  # trees and the new ./flake tree during migration.
  flakeModules,
}:
{
  hostname,
  user,
  system ? "x86_64-linux",
  # Physical disk to install/boot from, as a stable /dev/disk/by-id path.
  # Override per-call (or via `--arg diskDevice ...` / disko-install's own
  # `--disk main <device>` flag) when installing onto different hardware —
  # you should never need to hand-edit disko-config.nix.
  diskDevice,
}:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs diskDevice user flakeModules; };
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
        inherit inputs;
      };
      home-manager.users.${user} = {
        imports = [
          ../home/${user}
          ../hosts/${hostname}/home.nix
        ];
      };

      nixpkgs.overlays = [
        (final: prev: {
          dashlane-cli = final.callPackage ../pkgs/dashlane-cli.nix { };
        })
      ];
    }
  ];
}
