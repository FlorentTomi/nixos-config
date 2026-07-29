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

  programs.gamemode.enable = true;

  # Streams games out of THIS machine (the gaming desktop). Moonlight, the
  # client counterpart, lives in home/profiles/gaming.nix instead — a host
  # only ever needs one side of this pair.
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = false;
  };
}
