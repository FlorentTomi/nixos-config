{
  flake.modules.homeManager.gimp =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.gimp ];
    };
}
