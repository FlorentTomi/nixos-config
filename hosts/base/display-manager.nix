{ ... }:
{
  services.xserver.enable = true;

  services.displayManager.defaultSession = "niri";
  services.displayManager.sddm.enable = false;
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "dur_file";
      dur_file_path = "${./resources/blackhole-smooth-240x67.dur}";
      bg = "0x00000000";
      fg = "0x00FFFFFF";
      border_fg = "0x00FFFFFF";
    };
  };

  # services.displayManager.generic.execCmd = lib.mkForce ''
  #   exec ${pkgs.kmscon}/bin/kmscon --font-engine unifont --vt=tty1 --no-libseat --login -- ${pkgs.ly}/bin/ly --use-kmscon-vt
  # '';
}
