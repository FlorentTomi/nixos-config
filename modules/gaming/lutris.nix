{
  homeManager.modules.lutris =
    { pkgs, ... }:
    {
      programs.lutris.enable = true;
      home.packages = [ pkgs.protonup-qt ];
    };
}
