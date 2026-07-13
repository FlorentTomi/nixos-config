{ ... }:
{
  imports = [
    ./programs/tools.nix
    ./programs/gaming.nix
    ./programs/development.nix
    ./programs/desktop-environment.nix
  ];

  home = {
    username = "ftomi";
    homeDirectory = "/home/ftomi";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
