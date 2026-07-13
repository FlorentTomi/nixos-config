{ pkgs, ... }:

{
  programs.btop.enable = true;
  programs.bat.enable = true;
  programs.neovim.enable = true;

  programs.ghostty = {
    enable = true;
    settings.background-opacity = 0.9;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fastfetch
    '';
  };

  stylix.targets.starship.colors.enable = false;
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    presets = [ "tokyo-night" ];
  };

  programs.fastfetch.enable = true;

  home.packages = [
    pkgs.gdu
  ];
}
