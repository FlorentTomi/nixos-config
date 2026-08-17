{ pkgs, ... }:

{
  home.packages = [
    pkgs.scrcpy
    pkgs.android-tools
  ];
}
