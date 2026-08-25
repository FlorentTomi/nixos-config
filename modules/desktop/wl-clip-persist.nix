{
  flake.modules.homeManager.wl-clip-persist = {
    services.wl-clip-persist = {
      enable = true;
      clipboardType = "both";
    };
  };
}
