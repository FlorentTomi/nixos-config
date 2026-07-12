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
    presets = [ "tokyo-night" ];
  };

  programs.fastfetch.enable = true;
}
