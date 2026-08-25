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
    system = hostCfg.system;
    specialArgs = {
      inherit inputs;
      inherit (hostCfg) user diskDevice;
    };
    modules = [
      config.flake.modules.nixos.base
      config.flake.modules.nixos.gaming-desktop
      config.flake.modules.nixos.niri
      config.flake.modules.nixos.nvidia
      config.flake.modules.nixos.openvpn
      config.flake.modules.nixos.console
      config.flake.modules.nixos.virtualisation
      config.flake.modules.nixos.khal
      config.flake.modules.nixos.display-manager
      config.flake.modules.nixos.automount

      ../../hosts/ftomi-nixos/hardware-configuration.nix
      ../../hosts/ftomi-nixos/disko-config.nix
      ../../hosts/ftomi-nixos/users.nix
      ../../hosts/ftomi-nixos/boot.nix
      ../../hosts/ftomi-nixos/networking.nix
      ../../hosts/ftomi-nixos/fstrim.nix
      ../../hosts/ftomi-nixos/smartd.nix
      ../../hosts/ftomi-nixos/bluetooth.nix
      ../../hosts/ftomi-nixos/binfmt.nix

      {
        home-manager.users.${hostCfg.user} = {
          home.username = hostCfg.user;
          home.homeDirectory = "/home/${hostCfg.user}";
          home.stateVersion = "26.05";
          programs.home-manager.enable = true;

          imports = [
            ../../hosts/ftomi-nixos/monitors.nix
            config.flake.modules.homeManager.niri
            config.flake.modules.homeManager.git
            config.flake.modules.homeManager.nix-lang-tooling
            config.flake.modules.homeManager.gaming-desktop
            config.flake.modules.homeManager.audio
            config.flake.modules.homeManager.networking
            config.flake.modules.homeManager.tailscale
            config.flake.modules.homeManager.secrets
            config.flake.modules.homeManager.khal
            config.flake.modules.homeManager.lock-idle
            config.flake.modules.homeManager.fish
            config.flake.modules.homeManager.ghostty
            config.flake.modules.homeManager.floorp
            config.flake.modules.homeManager.zed
            config.flake.modules.homeManager.walker
            config.flake.modules.homeManager.wleave
            config.flake.modules.homeManager.bat
            config.flake.modules.homeManager.btop
            config.flake.modules.homeManager.nirimon
            config.flake.modules.homeManager.nix-index
            config.flake.modules.homeManager.starship
            config.flake.modules.homeManager.fastfetch
            config.flake.modules.homeManager.diskonaut
            config.flake.modules.homeManager.sops-env
            config.flake.modules.homeManager.mako
            config.flake.modules.homeManager.swayosd
            config.flake.modules.homeManager.playerctld
            config.flake.modules.homeManager.wl-clip-persist
            config.flake.modules.homeManager.gnome-keyring
            config.flake.modules.homeManager.wallpaper
            config.flake.modules.homeManager.vscode
            config.flake.modules.homeManager.direnv
            config.flake.modules.homeManager.nodejs
            config.flake.modules.homeManager.claude-code
            config.flake.modules.homeManager.helix
            config.flake.modules.homeManager.gimp
            config.flake.modules.homeManager.inkscape
            config.flake.modules.homeManager.onlyoffice
            config.flake.modules.homeManager.joplin
            config.flake.modules.homeManager.android-tools
            config.flake.modules.homeManager.discord
            config.flake.modules.homeManager.matrix
            config.flake.modules.homeManager.orca-slicer
            config.flake.modules.homeManager.qobuz
            config.flake.modules.homeManager.chromium
            config.flake.modules.homeManager.qalculate
            config.flake.modules.homeManager.work
            config.flake.modules.homeManager.ssh-ftomi-rpi
            config.flake.modules.homeManager.yazi
            config.flake.modules.homeManager.theme
            config.flake.modules.homeManager.colorscheme
            config.flake.modules.homeManager.waybar
            config.flake.modules.homeManager.eww
            config.flake.modules.homeManager.automount
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
