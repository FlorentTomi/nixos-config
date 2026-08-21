{ config, inputs, ... }:
let
  hostCfg = config.hosts.ftomi-nixos;
in
{
  hosts.ftomi-nixos = {
    user = "ftomi";
    diskDevice = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_M.2_250GB_S33CNX0H801497R";
  };

  flake.nixosConfigurations.ftomi-nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      inherit (hostCfg) user diskDevice;
    };
    modules = [
      config.nixos.modules.base
      config.nixos.modules.gaming-desktop
      config.nixos.modules.niri
      config.nixos.modules.nvidia
      config.nixos.modules.openvpn
      config.nixos.modules.console
      config.nixos.modules.virtualisation
      config.nixos.modules.khal
      config.nixos.modules.display-manager

      ../../hosts/ftomi-nixos/hardware-configuration.nix
      ../../hosts/ftomi-nixos/disko-config.nix
      ../../hosts/ftomi-nixos/users.nix
      ../../hosts/ftomi-nixos/boot.nix
      ../../hosts/ftomi-nixos/networking.nix
      ../../hosts/ftomi-nixos/fstrim.nix
      ../../hosts/ftomi-nixos/smartd.nix
      ../../hosts/ftomi-nixos/bluetooth.nix

      {
        home-manager.users.${hostCfg.user} = {
          home.username = hostCfg.user;
          home.homeDirectory = "/home/${hostCfg.user}";
          home.stateVersion = "26.05";
          programs.home-manager.enable = true;

          imports = [
            ../../hosts/ftomi-nixos/monitors.nix
            config.homeManager.modules.niri
            config.homeManager.modules.git
            config.homeManager.modules.nix-lang-tooling
            config.homeManager.modules.gaming-desktop
            config.homeManager.modules.audio
            config.homeManager.modules.networking
            config.homeManager.modules.tailscale
            config.homeManager.modules.secrets
            config.homeManager.modules.khal
            config.homeManager.modules.lock-idle
            config.homeManager.modules.fish
            config.homeManager.modules.ghostty
            config.homeManager.modules.floorp
            config.homeManager.modules.zed
            config.homeManager.modules.walker
            config.homeManager.modules.wleave
            config.homeManager.modules.bat
            config.homeManager.modules.btop
            config.homeManager.modules.nix-index
            config.homeManager.modules.starship
            config.homeManager.modules.fastfetch
            config.homeManager.modules.diskonaut
            config.homeManager.modules.sops-env
            config.homeManager.modules.mako
            config.homeManager.modules.swayosd
            config.homeManager.modules.playerctld
            config.homeManager.modules.wl-clip-persist
            config.homeManager.modules.gnome-keyring
            config.homeManager.modules.wallpaper
            config.homeManager.modules.vscode
            config.homeManager.modules.direnv
            config.homeManager.modules.nodejs
            config.homeManager.modules.claude-code
            config.homeManager.modules.helix
            config.homeManager.modules.gimp
            config.homeManager.modules.inkscape
            config.homeManager.modules.onlyoffice
            config.homeManager.modules.joplin
            config.homeManager.modules.android-tools
            config.homeManager.modules.discord
            config.homeManager.modules.matrix
            config.homeManager.modules.orca-slicer
            config.homeManager.modules.qobuz
            config.homeManager.modules.chromium
            config.homeManager.modules.qalculate
            config.homeManager.modules.work
            config.homeManager.modules.yazi
            config.homeManager.modules.theme
            config.homeManager.modules.waybar
            config.homeManager.modules.eww
          ];
        };

        custom.openvpn.configs = [
          {
            name = "pytheas_prod";
            hasAuth = true;
          }
          {
            name = "pytheas_infra";
            hasAuth = true;
          }
        ];

        sops.defaultSopsFile = ../../hosts/ftomi-nixos/secrets.yaml;
        system.stateVersion = "26.05";
      }
    ];
  };
}
