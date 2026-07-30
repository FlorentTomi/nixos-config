{ pkgs, ... }:
{
  # services.xserver.enable = true;
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  # };

  environment.systemPackages = [
    pkgs.tuigreet
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };

  services.displayManager.defaultSession = "niri";
}
