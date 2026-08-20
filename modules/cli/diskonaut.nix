{
  homeManager.modules.diskonaut =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.diskonaut-ng ];
    };
}
