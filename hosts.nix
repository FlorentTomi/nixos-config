# Host definitions, fed to lib/mk-host.nix. One attrset per nixosConfiguration.
{ mkHost }:
{
  ftomi-nixos = mkHost {
    hostname = "ftomi-nixos";
    user = "ftomi";
    homeProfiles = [
      "shell"
      "dual-monitor"
      "waybar"
      "launcher"
      "lock"
      "powermenu"
      "session"
      "yazi"
      "gaming"
      "hobbies"
      # "ollama"
      "audio"
      "work"
    ];
    diskDevice = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_M.2_250GB_S33CNX0H801497R";
  };
}
