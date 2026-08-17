{ pkgs, ... }:

{
  home.packages = [
    pkgs.sops
    pkgs.age
    pkgs.dashlane-cli
  ];
}
