{ pkgs, ... }:
{
  programs.coolercontrol.enable = true;

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [ via ];
  services.udev.packages = [ pkgs.via ];

  hardware.bluetooth.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit").indexOf("openvpn-") == 0 &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
}
