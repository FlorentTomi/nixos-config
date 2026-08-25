{
  flake.modules.homeManager.inkscape =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.inkscape ];
    };
}
