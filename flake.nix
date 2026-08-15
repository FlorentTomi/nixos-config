{
  description = "NixOS system + Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
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
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };

    # Backend data-provider service Walker talks to over a Unix socket —
    # not optional, even for plain drun-style app search (see
    # home/profiles/launcher-walker.nix). Pinned via walker's own
    # `inputs.elephant.follows` below so the two are always built from a
    # matching pair of versions, same as any other paired inputs here.
    elephant = {
      url = "github:abenz1267/elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      nix-index-database,
      ...
    }@inputs:
    let
      mkHost = import ./lib/mk-host.nix {
        inherit
          inputs
          home-manager
          sops-nix
          nix-index-database
          ;
      };
    in
    {
      nixosConfigurations = import ./hosts.nix { inherit mkHost; };
    };
}
