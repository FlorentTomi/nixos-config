{
  description = "NixOS system + Home Manager";

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
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      qylock,
      sops-nix,
      nix-index-database,
      ...
    }@inputs:
    let
      # One host = one hardware/identity dir under ./hosts, plus which
      # Home Manager feature-profile that user should get on that host.
      # Desktop environment (niri, stylix, ...) is each host's own choice,
      # wired from its own imports (see modules/niri.nix, profiles/ftomi/stylix.nix).
      mkHost =
        {
          hostname,
          user,
          homeProfile,
          system ? "x86_64-linux",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}
            home-manager.nixosModules.home-manager
            qylock.nixosModules.default
            sops-nix.nixosModules.sops
            nix-index-database.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = {
                inherit inputs;
              };
              home-manager.users.${user} = import ./home/${homeProfile} {};

              nixpkgs.overlays = [
                (final: prev: {
                  dashlane-cli = final.callPackage ./pkgs/dashlane-cli.nix { };
                })
              ];
            }
          ];
        };
    in
    {
      nixosConfigurations.ftomi-nixos = mkHost {
        hostname = "ftomi-nixos";
        user = "ftomi";
        homeProfile = "ftomi-desktop";
      };
    };

}
