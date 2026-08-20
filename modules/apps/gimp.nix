{
  homeManager.modules.gimp =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.gimp ];
    };
}
