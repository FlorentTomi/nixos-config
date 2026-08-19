{ ... }:
{
  imports = [
    ./git.nix
    ./zed.nix
    ./nil.nix
    ./nixd.nix
    ./niri.nix
    ./floorp.nix
    ./ghostty.nix
    ./fish.nix
  ];

  home = {
    username = "ftomi";
    homeDirectory = "/home/ftomi";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
