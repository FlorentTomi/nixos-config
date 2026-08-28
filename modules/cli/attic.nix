{
  flake.modules.homeManager.attic =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.attic-client ];
    };
}
