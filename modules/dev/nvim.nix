{
  flake.modules.homeManager.nvim = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      waylandSupport = true;
    };
  };
}
