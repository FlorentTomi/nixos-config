# Reproduces the pre-dendritic `outputs.nixosConfigurations` verbatim, just
# routed through flake-parts instead of being assembled directly in flake.nix.
# hosts.nix and lib/mk-host.nix are untouched in this step — this file only
# changes *how* their result gets attached to the flake's outputs.
{ inputs, ... }:
{
  flake.nixosConfigurations = import ../hosts.nix {
    mkHost = import ../lib/mk-host.nix {
      inherit inputs;
      inherit (inputs) home-manager sops-nix nix-index-database;
    };
  };
}
