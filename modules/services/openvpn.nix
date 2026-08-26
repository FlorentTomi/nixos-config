{
  flake.modules.nixos.openvpn =
    {
      config,
      lib,
      pkgs,
      user,
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
                description = "VPN identifier. Fetched from Proton Pass at start time as note item \"<name>\", plus a login item \"<name>-auth\" (in VPN vault) if `hasAuth` is set.";
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

        # Owned by the desktop user (not root) — vpn-pass-fetch runs as
        # that user, since it's the one with the Proton Pass session. Root
        # (openvpn) can still read these regardless of the 0700/0600 bits,
        # since root bypasses standard file permission checks.
        systemd.tmpfiles.rules = [
          "d /run/openvpn-secrets 0700 ${user} ${config.users.users.${user}.group} -"
        ];

        services.openvpn.servers = lib.listToAttrs (
          map (c: {
            name = c.name;
            value = {
              config = ''
                config /run/openvpn-secrets/${c.name}
              ''
              + lib.optionalString c.hasAuth ''
                auth-user-pass /run/openvpn-secrets/${c.name}-auth
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
