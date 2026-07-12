{ ... }:

{
  services = {
    polkit-gnome.enable = true;
    network-manager-applet.enable = true;
    swayidle.enable = true;
    mako.enable = true;
    swayosd.enable = true;
    awww.enable = true;
    tailscale-systray.enable = true;
    playerctld.enable = true;
    wl-clip-persist = {
      enable = true;
      clipboardType = "both";
    };
  };
}
