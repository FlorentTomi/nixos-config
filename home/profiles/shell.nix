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

  programs.television = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.ghostty = {
    enable = true;
    settings.background-opacity = 0.9;
  };

  # Mod+Return (terminal) and Mod+P (btop-in-terminal) live here since both
  # spawn ghostty, which this file owns.
  programs.niri.settings.binds = {
    "Mod+Return".action.spawn = "ghostty";
    "Mod+P".action.spawn = [
      "ghostty"
      "--confirm-close-surface=false"
      "-e"
      "btop"
    ];
  };

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

  # Stylix only defines starship's colors; the prompt's shape (segments,
  # icons) comes from a named preset, which Stylix doesn't provide. themeName
  # (from flake.nix) is reused here so the preset name stays linked to the
  # base16Scheme — if you switch schemes and no matching preset exists,
  # override `presets` locally.
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
