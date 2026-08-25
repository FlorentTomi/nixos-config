# Every host gets this — hardware-independent infra + the pieces that
# previously lived in lib/mk-host.nix and hosts/base/*.
{ config, inputs, ... }:
{
  flake.modules.nixos.base.imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.nix-index-database.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";
      home-manager.extraSpecialArgs = {
        inherit inputs;
      };
      nixpkgs.overlays = [
        (final: prev: {
          dashlane-cli = final.callPackage ../../pkgs/dashlane-cli.nix { };
        })
      ];
    }
  ]
  ++ (
    with config.flake.modules.nixos;
    [
      core-nix
      audio
      dconf
      xdg-portal
      bootloader
      zram
      networking
      tailscale
      secrets
      nix-ld
      envfs
      btrbk
      oomd
      locale
    ]
  );
}
