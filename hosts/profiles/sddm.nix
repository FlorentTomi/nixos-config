{ inputs, ... }:
{
  imports = [ inputs.sddm-qylock.nixosModules.default ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  programs.qylock = {
    enable = true;
    theme = "pixel-night-city";
  };
}
