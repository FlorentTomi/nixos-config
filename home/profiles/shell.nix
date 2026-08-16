{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  vpnNames = import ./resources/vpn-names.nix { inherit osConfig; };
in
{
  programs.btop.enable = true;
  programs.bat.enable = true;

  programs.ghostty = {
    enable = true;
    settings.font-family = "JetBrainsMono Nerd Font";
    settings.background-opacity = 0.9;
    settings.copy-on-select = true;
  };

  wayland.windowManager.niri.settings.binds."Mod+Return".spawn = [ "ghostty" ];
  wayland.windowManager.niri.settings.binds."Mod+Escape".spawn = [
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

  xdg.configFile."fish/completions/vpn.fish".text = ''
    complete -c vpn -f
    complete -c vpn -n 'test (count (commandline -opc)) = 1' -a '${lib.concatStringsSep " " vpnNames}' -d 'VPN name'
    complete -c vpn -n 'test (count (commandline -opc)) = 2' -a 'on off status start stop' -d 'action'
  '';

  programs.nix-index.enableFishIntegration = true;

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    presets = [ "catppuccin-powerline" ];
    settings = {
      palette = "catppuccin_mocha";
    };
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      display.separator = ": ";
      modules = [
        "title"
        "os"
        "kernel"
        "uptime"
        "cpu"
        {
          type = "gpu";
          detectionMethod = "vulkan";
          format = "{2}";
        }
        "memory"
        "disk"
      ];
    };
  };

  home.packages = [
    pkgs.diskonaut-ng
  ];

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/key.txt";
  };
}
