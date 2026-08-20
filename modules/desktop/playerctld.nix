{
  homeManager.modules.playerctld =
    { pkgs, ... }:
    {
      services.playerctld.enable = true;

      home.packages = [ pkgs.playerctl ];
    };
}
