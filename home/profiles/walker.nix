{
  inputs,
  catppuccinCss,
  pkgs,
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

  wayland.windowManager.niri.settings.binds = {
    "Mod+Space".spawn = [ "walker" ];
  };
}
