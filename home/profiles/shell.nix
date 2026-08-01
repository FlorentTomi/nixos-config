{ pkgs, themeName, ... }:

{
  programs.btop.enable = true;
  programs.bat.enable = true;
  programs.neovim.enable = true;

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
  };

  programs.ghostty = {
    enable = true;
    settings.background-opacity = 0.9;
    settings.copy-on-select = true;
  };

  programs.niri.settings.binds."Mod+Return".action.spawn = "ghostty";
  programs.niri.settings.binds."Mod+P".action.spawn = [
    "ghostty"
    "--confirm-close-surface=false"
    "-e"
    "btop"
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fastfetch
    '';

    functions.vpn = ''
      set -l name $argv[1]
      set -l action $argv[2]

      switch $action
        case on start
          systemctl start openvpn-$name
        case off stop
          systemctl stop openvpn-$name
        case status
          systemctl status openvpn-$name --no-pager
        case '*'
          echo "usage: vpn <n> <on|off|status>"
      end
    '';
  };

  programs.nix-index.enableFishIntegration = true;

  stylix.targets.starship.colors.enable = false;
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    presets = [ themeName ];
  };

  programs.fastfetch.enable = true;

  home.packages = [
    pkgs.gdu
  ];

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/key.txt";
  };
}
