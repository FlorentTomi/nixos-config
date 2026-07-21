{ profile ? ./profiles/desktop.nix, ... }:
{
  imports = [
    ./common/tools.nix
    ./common/development.nix
    ./common/desktop-environment.nix
    profile
  ];

  home = {
    username = "ftomi";
    homeDirectory = "/home/ftomi";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
