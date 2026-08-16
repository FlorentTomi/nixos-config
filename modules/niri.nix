{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.niri;
in
{
  options.modules.niri.enable = lib.mkEnableOption "niri window manager";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    programs.niri.package = pkgs.niri;

    xdg.portal.config.niri = {
      default = lib.mkForce [
        "gnome"
        "wlr"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };

    security.polkit.enable = true;
    systemd.user.services.niri-polkit-agent = {
      description = "PolicyKit Authentication Agent (polkit-kde-agent)";
      wantedBy = [ "niri.service" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
