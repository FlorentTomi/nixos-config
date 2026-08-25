{
  flake.modules.homeManager.android-tools =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.scrcpy
        pkgs.android-tools
      ];
    };
}
