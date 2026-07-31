{ inputs, pkgs, ... }:
let
  tuigreet = inputs.tuigreet.packages.${pkgs.stdenv.hostPlatform.system}.tuigreet;
in
{
  # services.xserver.enable = true;
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  # };

  environment.systemPackages = [
    tuigreet
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${tuigreet}/bin/tuigreet";
        user = "greeter";
      };
    };
  };

  services.displayManager.defaultSession = "niri";

  systemd.tmpfiles.rules = [
    "d /var/cache/tuigreet 0755 greeter greeter -"
  ];
}
