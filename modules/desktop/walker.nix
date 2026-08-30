{
  flake.modules.homeManager.walker =
    {
      inputs,
      themePalette,
      osConfig,
      pkgs,
      lib,
      ...
    }:
    let
      vpnNames = import ../../lib/vpn-names.nix { inherit osConfig; };

      # Shared backend for the "menus:audio-mixer" walker/elephant menu: a
      # no-arg call lists current playback streams (sink-inputs) as
      # tab-separated "<index>\t<app-name>\t<volume%>\t<mute>" lines; called
      # again as `raise|lower|mute <sink-input-index>` it adjusts that one
      # stream via pactl, then the menu re-lists to reflect the change.
      audioMixerSelect = pkgs.writeShellApplication {
        name = "audio-mixer-select";
        runtimeInputs = [
          pkgs.pulseaudio
          pkgs.jq
        ];
        text = ''
          list() {
            pactl -f json list sink-inputs | jq -r '
              .[] | [
                .index,
                (.properties["application.name"] // .properties["media.name"] // "Unknown"),
                (.volume | to_entries[0].value.value_percent),
                .mute
              ] | @tsv
            '
          }

          case "''${1-}" in
            raise) pactl set-sink-input-volume "$2" +5% ;;
            lower) pactl set-sink-input-volume "$2" -5% ;;
            mute) pactl set-sink-input-mute "$2" toggle ;;
            "") ;;
            *)
              echo "usage: audio-mixer-select [raise|lower|mute] <sink-input-index>" >&2
              exit 1
              ;;
          esac

          list
        '';
      };

      # elephant's protonpass provider (internal/providers/protonpass/protonpass.go)
      # has two mismatches against Proton Pass CLI 2.3.1:
      #
      # 1. checkAvailable() blocks forever on `pass-cli test` to check auth before
      #    listing items. That subcommand doesn't exist at all in 2.3.1, so the
      #    check never succeeds and the provider never loads.
      # 2. initItems() runs `pass-cli item list --output json` and expects each
      #    item to carry a `content.content.Login` payload. But 2.3.1 only includes
      #    that payload when `--show-secrets` is passed; without it every item is
      #    silently classified as "not a login" and dropped, so results stay empty
      #    even once (1) is fixed.
      #
      # This shim intercepts both calls and leaves everything else untouched.
      protonpassCliShim = pkgs.writeShellApplication {
        name = "pass-cli";
        text = ''
          real=${pkgs.proton-pass-cli}/bin/pass-cli

          if [ "$#" -eq 1 ] && [ "$1" = "test" ]; then
            exec "$real" info >/dev/null 2>&1
          fi

          if [ "''${1-}" = "item" ] && [ "''${2-}" = "list" ]; then
            exec "$real" "$@" --show-secrets
          fi

          exec "$real" "$@"
        '';
      };

      vpnToggle = import ../../lib/vpn-toggle.nix { inherit pkgs; };

      # elephant menu definition (~/.config/elephant/menus/vpn.lua): lists VPNs
      # with live on/off state and toggles the matching openvpn-<name> unit on
      # select, via vpn-toggle.nix (same start/stop + Proton Pass secret
      # fetch/cleanup used by the `vpn` fish function in pytheas.nix). Registers
      # as walker/elephant provider "menus:vpn".
      vpnMenu = ''
        Name = "vpn"
        NamePretty = "VPN"
        Icon = "network-vpn"
        Cache = false

        function GetEntries()
            local entries = {}
            local vpns = {${lib.concatMapStringsSep ", " (n: "\"${n}\"") vpnNames}}

            for _, name in ipairs(vpns) do
                local handle = io.popen("systemctl is-active --quiet openvpn-" .. name .. " && echo on || echo off")
                local state = handle:read("*l")
                handle:close()

                table.insert(entries, {
                    Text = name,
                    Subtext = state == "on" and "connected" or "disconnected",
                    Icon = state == "on" and "network-vpn" or "network-vpn-disconnected",
                    Actions = {
                        toggle = "${vpnToggle}/bin/vpn-toggle " .. name .. " " .. (state == "on" and "stop" or "start"),
                    },
                })
            end

            return entries
        end
      '';

      # elephant menu definition (~/.config/elephant/menus/audio-mixer.lua): lists
      # every app currently playing audio with its volume/mute state, and exposes
      # raise/lower/mute actions per entry (bound to keys in
      # programs.walker.config.providers.actions."menus:audio-mixer" below).
      # Registers as walker/elephant provider "menus:audio-mixer".
      audioMixerMenu = ''
        Name = "audio-mixer"
        NamePretty = "Audio Mixer"
        Icon = "audio-volume-high"
        Cache = false

        function GetEntries()
            local entries = {}
            local handle = io.popen("${audioMixerSelect}/bin/audio-mixer-select")

            if handle then
                for line in handle:lines() do
                    local id, name, vol, mute = line:match("([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)")

                    if id then
                        table.insert(entries, {
                            Text = name,
                            Subtext = (mute == "true") and (vol .. " (muted)") or vol,
                            Icon = (mute == "true") and "audio-volume-muted" or "audio-volume-high",
                            Actions = {
                                raise = "${audioMixerSelect}/bin/audio-mixer-select raise " .. id,
                                lower = "${audioMixerSelect}/bin/audio-mixer-select lower " .. id,
                                mute = "${audioMixerSelect}/bin/audio-mixer-select mute " .. id,
                            },
                        })
                    end
                end
                handle:close()
            end

            if #entries == 0 then
                table.insert(entries, {
                    Text = "Nothing playing audio right now",
                    Subtext = "",
                })
            end

            return entries
        end
      '';
    in
    {
      services.elephant = {
        enable = true;
      };

      # GTK4/GSK picks Vulkan by default. Walker's daemon creates its window
      # hidden at startup and only realizes the Wayland surface on first
      # `set_visible(true)` (triggered by the first Mod+Space invocation),
      # which races niri's initial surface configure and forces a swapchain
      # recreation (vkAcquireNextImageKHR VK_ERROR_OUT_OF_DATE_KHR), costing
      # a dropped frame on that first open only. Forcing the GL renderer
      # avoids the Vulkan swapchain path entirely.
      systemd.user.services.walker.Service.Environment = [ "GSK_RENDERER=gl" ];

      home.packages = [ (lib.hiPrio protonpassCliShim) ];

      services.walker = {
        enable = true;
        systemd.enable = true;
        settings = {
          force_keyboard_focus = true;
          close_when_open = true;
          click_to_close = true;
          hide_quick_activation = true;
          hide_action_hints = true;

          placeholders.default = {
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

          providers.actions."menus:vpn" = [
            {
              action = "toggle";
              default = true;
              bind = "Return";
              after = "AsyncReload";
            }
          ];

          providers.actions.protonpass = [
            {
              action = "copy_password";
              default = true;
              bind = "Return";
            }
            {
              action = "copy_username";
              bind = "shift Return";
            }
            {
              action = "copy_2fa";
              bind = "ctrl Return";
            }
          ];

          providers.actions."menus:audio-mixer" = [
            {
              action = "raise";
              default = true;
              bind = "Return";
              after = "AsyncReload";
            }
            {
              action = "lower";
              bind = "ctrl Return";
              after = "AsyncReload";
            }
            {
              action = "mute";
              bind = "ctrl m";
              after = "AsyncReload";
            }
          ];
        };

        theme = {
          name = "custom";
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

      xdg.configFile = {
        "elephant/menus/vpn.lua".text = vpnMenu;
        "elephant/menus/audio-mixer.lua".text = audioMixerMenu;
      };

      home.activation.restartElephant = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
        run ${pkgs.systemd}/bin/systemctl --user try-restart elephant.service
      '';

      wayland.windowManager.niri.settings.binds = {
        "Mod+Space".spawn = [ "walker" ];
        "Mod+Shift+A".spawn = [
          "walker"
          "-m"
          "menus:audio-mixer"
        ];
      };
    };
}
