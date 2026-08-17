# Desktop-only extras: phone debugging, 3D-printing slicer, Discord.
# Deliberately not part of identity — not wanted on the work laptop.
{ ... }:
{
  imports = [
    ./discord.nix
    ./android-tools.nix
    ./orca-slicer.nix
  ];
}
