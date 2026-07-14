{ ... }:
{
  imports = [
    ./tools.nix
    ./gaming.nix
    ./development.nix
    ./desktop-environment.nix
    ./ollama.nix
  ];

  home = {
    username = "ftomi";
    homeDirectory = "/home/ftomi";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
