{
  flake.modules.nixos.steam = {
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
  };

  flake.modules.homeManager.steam = {
    wayland.windowManager.niri.settings._children = [
      {
        window-rule._children = [
          {
            match._props.app-id = "^steam_app_.*$";
            open-maximized = true;
          }
        ];
      }
    ];
  };
}
