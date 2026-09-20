{
  flake.modules.nixos.television = {
    programs.television.enable = true;
  };

  flake.modules.homeManager.television = {
    programs.television = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
