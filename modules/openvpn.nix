{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  cfg = config.modules.openvpn;
in
{
  imports = [ inputs.update-systemd-resolved.nixosModules.default ];

  options.modules.openvpn = {
    enable = lib.mkEnableOption "OpenVPN client connections";
    configs = lib.mkOption {
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
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          let
            names = map (c: c.name) cfg.configs;
          in
          (lib.length names) == (lib.length (lib.unique names));
        message = "modules.openvpn.configs contains duplicate names.";
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
  };
}
