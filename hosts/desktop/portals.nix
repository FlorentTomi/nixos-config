{ pkgs, ... }:
{
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-wlr
    ];
    config.common.default = [
      "gnome"
      "wlr"
    ];
    config.common."org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
  };
}
