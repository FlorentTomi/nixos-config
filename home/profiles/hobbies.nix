# Desktop-only extras: phone debugging, 3D-printing slicer, Discord.
# Deliberately not part of identity — not wanted on the work laptop.
{ pkgs, ... }:

{
  programs.discord.enable = true;

  home.packages = [
    pkgs.scrcpy
    pkgs.android-tools
    pkgs.orca-slicer
  ];
}
