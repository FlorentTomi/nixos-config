{
  flake.modules.homeManager.qobuz =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.qbz
      ];
    };
}
