{ ... }:
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;

  programs.qylock = {
    enable = true;
    theme = "pixel-night-city";
  };
}
