{ ... }:

{
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
    presets = [ "gruvbox-rainbow" ];
  };

  programs.fastfetch.enable = true;
}
