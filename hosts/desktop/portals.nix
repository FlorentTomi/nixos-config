{ pkgs, ... }:
{
  programs.dconf.enable = true;

  environment.systemPackages = [
    pkgs.fuse3
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [
        "gnome"
        "wlr"
      ];

      common."org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];

      niri = {
        default = [
          "gnome"
          "wlr"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };

  };
}
