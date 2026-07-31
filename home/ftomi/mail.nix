{ config, lib, ... }:

let
  gmailAddress = "florent.tomi@gmail.com";
in
{
  accounts.email.accounts."gmail" = {
    primary = true;
    address = gmailAddress;
    realName = "Florent Tomi";
    userName = gmailAddress;
    flavor = "gmail.com";

    thunderbird = {
      enable = true;
      profiles = [ "default" ];
    };
  };

  accounts.calendar.accounts = {
    "Perso" = {
      primary = true;
      remote = {
        type = "caldav";
        url = "https://apidata.googleusercontent.com/caldav/v2/${gmailAddress}/events";
        userName = gmailAddress;
      };
    };

    "Alexandre" = {
      remote = {
        type = "caldav";
        url = "https://apidata.googleusercontent.com/caldav/v2/56765a8fa2a68b7b6ec076345ae4d5b97935a333c6b30dc0ce86afbff5403dc8@group.calendar.google.com/events";
        userName = gmailAddress;
      };
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      withExternalGnupg = false;
    };
  };

  programs.thunderbird.settings =
    let
      safeName = n: builtins.replaceStrings [ "." "@" ] [ "-" "-" ] n;
      entry = name: cal: {
        "calendar.registry.${safeName name}.cache.enabled" = true;
        "calendar.registry.${safeName name}.calendar-main-default" = cal.primary;
        "calendar.registry.${safeName name}.calendar-main-in-composite" = true;
        "calendar.registry.${safeName name}.name" = name;
        "calendar.registry.${safeName name}.type" = "caldav";
        "calendar.registry.${safeName name}.uri" = cal.remote.url;
        "calendar.registry.${safeName name}.username" = cal.remote.userName;
      };
    in
    lib.attrsets.concatMapAttrs entry config.accounts.calendar.accounts;

  programs.niri.settings.window-rules = [
    {
      matches = [
        {
          app-id = "thunderbird$";
          title = "^Reminder$";
        }
      ];
      open-floating = true;
    }
  ];

  programs.niri.settings.binds."Mod+M".action.spawn = "thunderbird";
}
