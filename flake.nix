{
  description = "NixOS system + Home Manager - Niri";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qylock = {
      url = "github:Darkkal44/qylock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      niri,
      qylock,
      sops-nix,
      ...
    }@inputs:
    let
      # One host = one hardware/identity dir under ./hosts, plus which
      # Home Manager feature-profile that user should get on that host.
      # Everything else (stylix, niri, HM wiring, overlays) is shared.
      mkHost =
        {
          hostname,
          system ? "x86_64-linux",
          homeProfile ? ./home/profiles/desktop.nix,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}
            stylix.nixosModules.stylix
            niri.nixosModules.niri
            home-manager.nixosModules.home-manager
            qylock.nixosModules.default
            sops-nix.nixosModules.sops
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = {
                inherit inputs;
              };
              home-manager.users.ftomi = import ./home { profile = homeProfile; };

              programs.niri.enable = true;
              niri-flake.cache.enable = false;

              nixpkgs.overlays = [
                niri.overlays.niri
                (final: prev: {
                  dashlane-cli = final.callPackage ./pkgs/dashlane-cli.nix { };
                })
              ];
            }
          ];
        };
    in
    {
      nixosConfigurations.ftomi-nixos = mkHost { hostname = "ftomi-nixos"; };
    };

}
