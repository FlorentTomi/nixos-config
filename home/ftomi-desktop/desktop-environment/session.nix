{ pkgs, ... }:
{
  home.packages = [
    pkgs.waypaper
    pkgs.pamixer
    pkgs.pavucontrol
    pkgs.playerctl
  ];

  services = {
    polkit-gnome.enable = true;
    network-manager-applet.enable = true;
    swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 300;
          command = "hyprlock";
        }
        {
          timeout = 600;
          command = "niri msg action power-off-monitors";
          resumeCommand = "niri msg action power-on-monitors";
        }
      ];
      events = {
        before-sleep = "hyprlock";
        lock = "hyprlock";
      };
    };
    mako.enable = true;
    swayosd.enable = true;
    awww.enable = true;
    playerctld.enable = true;
    wl-clip-persist = {
      enable = true;
      clipboardType = "both";
    };
  };
}
