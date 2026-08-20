{
  nixos.modules.core-nix =
    { pkgs, user, inputs, ... }:
    {
      imports = [ inputs.catppuccin.nixosModules.catppuccin ];

      # nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.trace "UNFREE: ${pkg.name or pkg.pname or "unknown"}" true;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };

      # modules/theme.nix already sets this at the home-manager level, but
      # nix.settings written from home-manager scope isn't reliably picked up
      # by the system nix-daemon under NixOS integration — only NixOS-level
      # nix.settings is guaranteed to land in /etc/nix/nix.conf. Setting it
      # again here (same option, NixOS module this time) is what actually
      # wires up the substituter Catppuccin's whiskers-rendered outputs
      # (rofi, gtk, hyprlock, waybar, ...) get pulled from instead of
      # rebuilt locally on every relevant rebuild. Non-default flavor/accent
      # combos (we run mocha/mauve) may still miss the cache if upstream CI
      # only prebuilds the defaults — that's expected, not this bug.
      catppuccin.cache.enable = true;

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
