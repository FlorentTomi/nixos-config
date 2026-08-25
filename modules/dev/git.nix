{
  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings.user = {
        name = "Florent TOMI";
        email = "florent.tomi@outlook.com";
      };
    };

    programs.gh.enable = true;
    programs.lazygit.enable = true;
  };
}
