# Shared nixpkgs overlays, applied both to the NixOS-integrated
# home-manager module (lib/mk-host.nix) and the standalone home-manager
# configuration (lib/mk-home.nix) so `pkgs.dashlane-cli` resolves either way.
[
  (final: prev: {
    dashlane-cli = final.callPackage ../pkgs/dashlane-cli.nix { };
  })
]
