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
}
