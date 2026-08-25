{
  flake.modules.homeManager.orca-slicer =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.orca-slicer ];
    };
}
