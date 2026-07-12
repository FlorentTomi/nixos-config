{ ... }:
{
  imports = [
    ./programs/niri.nix
    ./programs/waybar.nix
    ./programs/shell.nix
    ./programs/tools.nix
    ./programs/yazi.nix
    ./programs/gaming.nix
    ./services.nix
  ];

  home = {
    username = "ftomi";
    homeDirectory = "/home/ftomi";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
