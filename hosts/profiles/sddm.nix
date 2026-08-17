{ pkgs, ... }:
let
  sddm-astronaut = (
    pkgs.sddm-astronaut.override {
      embeddedTheme = "jake_the_dog";
    }
  );
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
  };

  environment.systemPackages = [
    sddm-astronaut
  ];
}
