{
  homeManager.modules.qobuz =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.qbz
      ];
    };
}
