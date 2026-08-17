# Assumes profiles/hyprlock.nix is present (swayidle's timeouts/sleep
# events invoke it directly). Import both together.
{ ... }:
{
  imports = [
    ./waypaper.nix
    ./pamixer.nix
    ./pavucontrol.nix
    ./polkit-gnome.nix
    ./network-manager-applet.nix
    ./swayidle.nix
    ./mako.nix
    ./swayosd.nix
    ./awww.nix
    ./playerctld.nix
    ./wl-clip-persist.nix
  ];
}
