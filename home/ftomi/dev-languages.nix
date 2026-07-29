{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  home.packages = [
    pkgs.nodejs_22
    pkgs.nil
    pkgs.nixd
  ];
}
