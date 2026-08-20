{
  homeManager.modules.orca-slicer =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.orca-slicer ];
    };
}
