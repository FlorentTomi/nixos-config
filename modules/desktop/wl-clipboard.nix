{
  flake.modules.homeManager.wl-clipboard =
    { pkgs, ... }:
    {
      services.wl-clip-persist = {
        enable = true;
        clipboardType = "both";
      };

      home.packages = [ pkgs.wl-clipboard ];
    };
}
