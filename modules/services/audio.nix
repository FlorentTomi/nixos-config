{
  flake.modules.nixos.audio = {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };

  flake.modules.homeManager.audio =
    { pkgs, ... }:
    {
      services.pasystray.enable = true;
      home.packages = [
        pkgs.pamixer
        pkgs.pavucontrol
      ];
    };
}
