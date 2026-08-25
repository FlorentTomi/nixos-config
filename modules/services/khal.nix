{
  flake.modules.nixos.khal =
    { config, ... }:
    {
      sops.secrets."gcal-client-id" = {
        owner = "ftomi";
        mode = "0400";
      };

      sops.secrets."gcal-client-secret" = {
        owner = "ftomi";
        mode = "0400";
      };

      sops.templates."vdirsyncer-config" = {
        owner = "ftomi";
        mode = "0400";
        content = ''
          [general]
          status_path = "/home/ftomi/.vdirsyncer/status/"

          [pair google_calendar]
          a = "local"
          b = "google"
          collections = ["from b"]
          conflict_resolution = "b wins"

          [storage local]
          type = "filesystem"
          path = "/home/ftomi/.calendars/"
          fileext = ".ics"

          [storage google]
          type = "google_calendar"
          token_file = "/home/ftomi/.vdirsyncer/google_token"
          client_id = "${config.sops.placeholder."gcal-client-id"}"
          client_secret = "${config.sops.placeholder."gcal-client-secret"}"

          [pair shared_calendar]
          a = "shared_local"
          b = "shared_remote"
          collections = ["from a", "from b"]
          conflict_resolution = "b wins"

          [storage shared_local]
          type = "filesystem"
          path = "/home/ftomi/.calendars-shared/"
          fileext = ".ics"

          [storage shared_remote]
          type = "google_calendar"
          token_file = "/home/ftomi/.vdirsyncer/google_token"
          client_id = "${config.sops.placeholder."gcal-client-id"}"
          client_secret = "${config.sops.placeholder."gcal-client-secret"}"
          url = "https://apidata.googleusercontent.com/caldav/v2/56765a8fa2a68b7b6ec076345ae4d5b97935a333c6b30dc0ce86afbff5403dc8@group.calendar.google.com/events/"
        '';
      };
    };

  flake.modules.homeManager.khal =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.vdirsyncer ];
      programs.khal.enable = true;

      accounts.calendar.accounts = {
        "Alexandre" = {
          khal = {
            enable = true;
            color = "light green";
          };
          local = {
            type = "filesystem";
            fileExt = ".ics";
            path = "${config.home.homeDirectory}/.calendars-shared/56765a8fa2a68b7b6ec076345ae4d5b97935a333c6b30dc0ce86afbff5403dc8@group.calendar.google.com";
          };
        };
      };

      xdg.configFile."vdirsyncer/config".source =
        config.lib.file.mkOutOfStoreSymlink
          osConfig.sops.templates."vdirsyncer-config".path;
    };
}
