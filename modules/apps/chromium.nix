{
  homeManager.modules.chromium =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.ungoogled-chromium ];
    };
}
