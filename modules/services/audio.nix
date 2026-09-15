{
  flake.modules.nixos.audio = {
    nixpkgs.overlays = [ (import ../../pkgs/volctl.nix) ];

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;

      wireplumber.extraConfig."51-force-duplex-profile" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.name" = "~alsa_card.*"; }
            ];
            actions = {
              update-props = {
                "api.acp.auto-profile" = true;
                "api.acp.auto-port" = true;
              };
            };
          }
        ];
      };
    };
  };

  flake.modules.homeManager.audio =
    { pkgs, ... }:
    {
      systemd.user.services.volctl = {
        Unit.Description = "Per-application volume popup mixer";
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          ExecStart = "${pkgs.volctl}/bin/volctl";
          Restart = "on-failure";
        };
      };

      dconf.settings = {
        "apps.volctl" = {
          allow-extra-volume = true;
          mixer-command = "pavucontrol";
          mixer-position = "top-right";
          osd-enabled = false;
        };
      };

      home.packages = [
        pkgs.pamixer
        pkgs.pavucontrol
        pkgs.volctl
        pkgs.glib
      ];
    };
}
