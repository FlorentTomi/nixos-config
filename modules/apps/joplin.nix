{
  flake.modules.homeManager.joplin = {
    programs.joplin-desktop = {
      enable = true;
      sync.target = "none";
    };
  };
}
