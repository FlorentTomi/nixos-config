{
  homeManager.modules.nodejs =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nodejs_22 ];
    };
}
