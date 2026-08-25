{
  flake.modules.homeManager.lutris =
    { pkgs, ... }:
    {
      programs.lutris.enable = true;
      home.packages = [ pkgs.protonup-qt ];
    };
}
