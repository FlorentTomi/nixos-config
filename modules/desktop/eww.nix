{
  flake.modules.homeManager.eww = {
    programs.eww = {
      enable = true;
      systemd.enable = true;
    };
  };
}
