{ ... }:
{
  imports = [
    ./git.nix
    ./gh.nix
    ./lazygit.nix
    ./zed.nix
    ./vscode.nix
    ./joplin.nix
    ./gimp.nix
    ./inkscape.nix
    ./onlyoffice.nix
    ./claude-code.nix
    ./direnv.nix
    ./nodejs.nix
    ./nil.nix
    ./nixd.nix
    ./floorp.nix
    ./chromium.nix
    ./tailscale-systray.nix
    ./secrets-tools.nix
    ./niri.nix
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
