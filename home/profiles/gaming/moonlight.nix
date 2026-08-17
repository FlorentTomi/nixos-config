{ pkgs, ... }:

{
  # Streams games out of the gaming desktop (services.sunshine, at the
  # NixOS level — hosts/ftomi-nixos/sunshine.nix). This is the client side.
  home.packages = [ pkgs.moonlight-qt ];
}
