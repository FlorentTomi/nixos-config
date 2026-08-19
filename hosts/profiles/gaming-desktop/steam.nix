{ ... }:
{
  # Keep /games owned by ftomi even if root-owned files ever land there
  # (e.g. an installer step run via sudo/pkexec).
  systemd.tmpfiles.rules = [
    "d /games 0755 ftomi users -"
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = true;
  };
}
