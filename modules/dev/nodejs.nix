{
  flake.modules.homeManager.nodejs =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nodejs_22 ];
    };
}
