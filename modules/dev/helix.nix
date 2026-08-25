{
  flake.modules.homeManager.helix = {
    programs.helix = {
      enable = true;
    };

    home.sessionVariables.EDITOR = "hx";
  };
}
