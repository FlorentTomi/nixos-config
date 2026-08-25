{
  flake.modules.nixos.display-manager =
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

      security.pam.services.sddm.enableGnomeKeyring = true;

      environment.systemPackages = [
        sddm-astronaut
      ];
    };
}
