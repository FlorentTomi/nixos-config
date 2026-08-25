{
  flake.modules.homeManager.onlyoffice =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.onlyoffice-desktopeditors ];
    };
}
