{
  inputs,
  catppuccinCss,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.walker.homeManagerModules.default ];

  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      theme = "custom";
      force_keyboard_focus = true;
      close_when_open = true;
      click_to_close = true;
      hide_quick_activation = true;
      hide_action_hints = true;

      placeholders."default" = {
        input = "Search";
        list = "No results";
      };

      providers.prefixes = [
        {
          provider = "files";
          prefix = "/";
        }
        {
          provider = "providerlist";
          prefix = ";";
        }
      ];
    };

    themes.custom = {
      style = catppuccinCss {
        text = builtins.readFile ./resources/walker-style.css;
        extra = {
          background-image = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        };
      };
    };
  };

  # elephant's X-Restart-Triggers only fire on changes to its own Nix
  # options (settings/providers/provider/debug) — installing or removing
  # packages doesn't touch those, so its desktop-app index silently goes
  # stale after every switch. try-restart is a no-op if elephant isn't
  # running yet (e.g. first boot / headless rebuild over SSH), so this is
  # safe to run unconditionally.
  home.activation.restartElephant = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
    run ${pkgs.systemd}/bin/systemctl --user try-restart elephant.service
  '';

  wayland.windowManager.niri.settings.binds = {
    "Mod+Space".spawn = [ "walker" ];
  };
}
