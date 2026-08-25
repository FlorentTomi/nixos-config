{
  # pkgs.update-systemd-resolved is nixpkgs' own package
  # (pkgs/tools/networking/openvpn/update-systemd-resolved.nix) — the
  # jonathanio/update-systemd-resolved flake input previously imported here
  # only added options under programs.update-systemd-resolved.*, which
  # nothing in this config touches; the `up`/`down` script below has always
  # referenced the plain nixpkgs package directly, so removing the input
  # changes nothing.
  flake.modules.nixos.openvpn =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.custom.openvpn;
    in
    {
      options.custom.openvpn.configs = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "VPN identifier. Expects a `vpn-<name>` secret, and a `vpn-<name>-auth` secret if `hasAuth` is set.";
              };
              hasAuth = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether this VPN needs a separate username/password secret.";
              };
            };
          }
        );
        default = [ ];
        example = [
          {
            name = "work";
            hasAuth = true;
          }
          { name = "home"; }
        ];
      };

      config = {
        assertions = [
          {
            assertion =
              let
                names = map (c: c.name) cfg.configs;
              in
              (lib.length names) == (lib.length (lib.unique names));
            message = "custom.openvpn.configs contains duplicate names.";
          }
        ];

        sops.secrets = lib.listToAttrs (
          lib.flatten (
            map (
              c:
              [
                {
                  name = "vpn-${c.name}";
                  value = {
                    owner = "root";
                    mode = "0400";
                  };
                }
              ]
              ++ lib.optional c.hasAuth {
                name = "vpn-${c.name}-auth";
                value = {
                  owner = "root";
                  mode = "0400";
                };
              }
            ) cfg.configs
          )
        );

        services.openvpn.servers = lib.listToAttrs (
          map (c: {
            name = c.name;
            value = {
              config = ''
                config ${config.sops.secrets."vpn-${c.name}".path}
              ''
              + lib.optionalString c.hasAuth ''
                auth-user-pass ${config.sops.secrets."vpn-${c.name}-auth".path}
              ''
              + ''
                up ${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
                down ${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
                down-pre
                script-security 2
              '';
              autoStart = false;
              updateResolvConf = false;
            };
          }) cfg.configs
        );

        # Importing openvpn already implies wanting self-service management
        # of its units — no separate option needed.
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.systemd1.manage-units" &&
                action.lookup("unit").indexOf("openvpn-") == 0 &&
                subject.isInGroup("wheel")) {
              return polkit.Result.YES;
            }
          });
        '';
      };
    };
}
