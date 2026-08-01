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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    update-systemd-resolved = {
      url = "github:jonathanio/update-systemd-resolved";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
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
      # Single source of truth for the base16 scheme name. Consumed by
      # profiles/ftomi/stylix.nix (builds the base16Scheme file path) and by
      # home/profiles/shell.nix (starship preset name) — Stylix only owns
      # *colors*, not a prompt's shape, so the starship preset still has to be
      # picked by name. This just keeps the name from silently drifting
      # between the two. If you switch schemes and no matching starship
      # preset exists, override it locally in shell.nix.
      themeName = "tokyo-night";

      # One host = one hardware/identity dir under ./hosts, plus which
      # optional Home Manager profiles that user should get on that host.
      # `home/${user}` (identity: always-on regardless of host) is imported
      # unconditionally; homeProfiles are opt-in extras composed here so the
      # combination is visible at the call site instead of buried in a
      # bundle file. Desktop environment (niri, stylix, ...) at the NixOS
      # level is each host's own choice, wired from its own imports (see
      # modules/niri.nix, profiles/ftomi/stylix.nix).
      mkHost =
        {
          hostname,
          user,
          homeProfiles ? [ ],
          system ? "x86_64-linux",
          # Physical disk to install/boot from, as a stable /dev/disk/by-id path.
          # Override per-call (or via `--arg diskDevice ...` / disko-install's
          # own `--disk main <device>` flag) when installing onto different
          # hardware — you should never need to hand-edit disko-config.nix.
          diskDevice,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs diskDevice themeName; };
          modules = [
            ./hosts/${hostname}
            inputs.disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            qylock.nixosModules.default
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
                imports = [ ./home/${user} ] ++ map (p: ./home/profiles + "/${p}.nix") homeProfiles;
              };

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
        homeProfiles = [
          "shell"
          "dual-monitor"
          "waybar"
          "launcher"
          "lock"
          "powermenu"
          "session"
          "yazi"
          "gaming"
          "hobbies"
          # "ollama"
          "work"
        ];
        diskDevice = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_M.2_250GB_S33CNX0H801497R";
      };
    };
}
