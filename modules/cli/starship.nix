{
  homeManager.modules.starship = {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      presets = [ "catppuccin-powerline" ];
      settings = {
        palette = "catppuccin_mocha";
      };
    };
  };
}
