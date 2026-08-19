{ pkgs, ... }:
let
  sddm-astronaut = (
    pkgs.sddm-astronaut.override {
      embeddedTheme = "jake_the_dog";
    }
  );
in
{
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
    ];
  };

  environment.systemPackages = [
    sddm-astronaut
  ];
}
