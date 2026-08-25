{
  flake.modules.homeManager.diskonaut =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.diskonaut-ng ];
    };
}
