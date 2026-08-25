{
  homeManager.modules.walker =
    {
      inputs,
      themePalette,
      osConfig,
      pkgs,
      lib,
      ...
    }:
    let
      vpnNames = import ../../resources/vpn-names.nix { inherit osConfig; };
    in
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
            {
              provider = "menus:vpn";
              prefix = "&";
            }
          ];
        };

        themes.custom = {
          style = ''
            ${builtins.readFile ../../resources/walker-style.css}
            .box-wrapper {
              background-image:
                linear-gradient(
                  alpha(#${themePalette.background}, 0.9),
                  alpha(#${themePalette.background-alt}, 0.95)
                ),
                url(${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg);
            }

            * {
              color: #${themePalette.text};
            }

            .box-wrapper {
                border: 2px solid #${themePalette.background-alt};
            }

            .search-container {
                background: alpha(#${themePalette.background-alt}, 0.8);
                border-bottom: 2px solid #${themePalette.accent};
            }

            .input {
                color: #${themePalette.text};
            }

            child:hover .item-box,
            child:selected .item-box {
                background: linear-gradient(
                    90deg,
                    alpha(#${themePalette.dark.background-list-selected}, 0.4) 0%,
                    alpha(#${themePalette.background}, 0) 100%
                );
                border-left: 2px solid #${themePalette.accent};
            }

            child:selected .item-box * {
                color: #${themePalette.text};
            }
          '';
        };
      };

      xdg.configFile."elephant/menus/vpn.lua".text = import ../../resources/vpn-menu.nix {
        inherit lib vpnNames;
      };

      home.activation.restartElephant = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
        run ${pkgs.systemd}/bin/systemctl --user try-restart elephant.service
      '';

      wayland.windowManager.niri.settings._children = [
        {
          spawn-at-startup._args = [
            "walker"
            "--gapplication-service"
          ];
        }
      ];

      wayland.windowManager.niri.settings.binds = {
        "Mod+Space".spawn = [ "walker" ];
      };
    };
}
