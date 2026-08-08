{
  pkgs,
  lib,
  osConfig,
  themeName,
  ...
}:

let
  # osConfig's own VPN list (modules/openvpn.nix), not a systemctl unit-name
  # glob: services.openvpn also creates its own internal units matching
  # "openvpn-*" (e.g. openvpn-restart.service, a sleep/resume hook) that
  # aren't actual VPNs and would otherwise leak into completions.
  vpnNames = map (c: c.name) osConfig.modules.openvpn.configs;
in

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
  programs.niri.settings.binds."Mod+Escape".action.spawn = [
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
