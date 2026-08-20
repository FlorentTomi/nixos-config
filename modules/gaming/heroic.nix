{
  homeManager.modules.heroic =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.heroic ];
    };
}
