{ pkgs, ... }:
{
  programs.coolercontrol.enable = true;

  environment.systemPackages = with pkgs; [ via ];
  services.udev.packages = [ pkgs.via ];
}
