{
  homeManager.modules.inkscape =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.inkscape ];
    };
}
