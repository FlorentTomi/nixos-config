# Builds one standalone home-manager configuration from a host definition
# (see ../hosts.nix), reusing the same home/${user} + homeProfiles as the
# NixOS-integrated home-manager module in mk-host.nix, so `nh home switch`
# can activate just the home-manager half without a full `nh os switch`.
#
# `osConfig` is pulled from the matching nixosConfiguration so profiles
# that read NixOS-level values (VPN names, sops secret paths, the nvidia
# flag, xkb layout, ...) keep working standalone instead of being
# duplicated here.
{ inputs, home-manager }:
{
  user,
  hostname,
  homeProfiles ? [ ],
  system ? "x86_64-linux",
  ...
}:
home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = import ./overlays.nix;
    # Mirrors hosts/base/nix.nix, which standalone home-manager doesn't see.
    config.allowUnfree = true;
  };
  extraSpecialArgs = {
    inherit inputs;
    osConfig = inputs.self.nixosConfigurations.${hostname}.config;
  };
  modules = [
    ../home/${user}
    # Standalone home-manager (unlike the NixOS module) doesn't inherit
    # nix.package from the system config, but needs one to render nix.conf.
    { nix.package = inputs.nixpkgs.legacyPackages.${system}.nix; }
  ] ++ map (p: ../home/profiles + "/${p}.nix") homeProfiles;
}
