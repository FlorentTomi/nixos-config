{
  nixos.modules.audio = {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };

  homeManager.modules.audio =
    { pkgs, ... }:
    {
      services.pasystray.enable = true;
      home.packages = [
        pkgs.pamixer
        pkgs.pavucontrol
      ];
    };
}
