{ ... }:
{
  imports = [
    ./vcs.nix
    ./editors.nix
    ./ai-tools.nix
    ./dev-languages.nix
    ./browser.nix
    ./security.nix
    ./niri-core.nix
    ./theme.nix
    ./neovim.nix
  ];

  home = {
    username = "ftomi";
    homeDirectory = "/home/ftomi";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
