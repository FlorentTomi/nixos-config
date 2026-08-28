{
  flake.modules.nixos.core-nix =
    { pkgs, user, ... }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg: builtins.trace "UNFREE: ${pkg.name or pkg.pname or "unknown"}" true;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        substituters = [ "https://nix-community.cachix.org" ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      # nh replaces raw nix.gc below: it can enforce a *count* floor
      # (--keep) alongside the age cutoff (--keep-since), so a quiet week
      # can't silently GC every rollback generation down to just "current".
      # Plain nix.gc only understands age, which is why it's left disabled
      # here rather than run alongside nh (avoids two GC policies fighting).
      programs.nh = {
        enable = true;
        flake = "/home/${user}/nixos-config";
        clean = {
          enable = true;
          dates = "daily";
          extraArgs = "--keep 5 --keep-since 2d";
        };
      };

      environment.systemPackages = [
        pkgs.nix-output-monitor # nh shells out to `nom` automatically when it's on PATH
      ];

      nix.gc.automatic = false;
    };
}
