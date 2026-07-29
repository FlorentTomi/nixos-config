{ pkgs, ... }:

{
  home.packages = [
    pkgs.sops
    pkgs.age
    pkgs.dashlane-cli
  ];

  services.tailscale-systray.enable = true;
}
