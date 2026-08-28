{ config, inputs, ... }:
let
  hostCfg = config.hosts.ftomi-rpi;
in
{
  hosts.ftomi-rpi = {
    user = "ftomi";
    system = "aarch64-linux";
  };

  flake.nixosConfigurations.ftomi-rpi = inputs.nixpkgs.lib.nixosSystem {
    inherit (hostCfg) system;
    specialArgs = {
      inherit inputs;
      inherit (hostCfg) user diskDevice;
    };
    modules = [
      config.flake.modules.nixos.headless-arm
      config.flake.modules.nixos.virtualisation
      config.flake.modules.nixos.caddy
      config.flake.modules.nixos.dnsmasq
      config.flake.modules.nixos.bambuddy
      config.flake.modules.nixos.attic-cache

      ../../hosts/ftomi-rpi/hardware-configuration.nix
      ../../hosts/ftomi-rpi/sd-image.nix
      ../../hosts/ftomi-rpi/filesystems.nix
      ../../hosts/ftomi-rpi/boot.nix
      ../../hosts/ftomi-rpi/networking.nix
      ../../hosts/ftomi-rpi/users.nix

      (
        { pkgs, ... }:
        {
          custom.virtualisation.nvidiaContainerToolkit = false;
          custom.virtualisation.dockerUsers = [ hostCfg.user ];
          sops.defaultSopsFile = ../../hosts/ftomi-rpi/secrets.yaml;
          system.stateVersion = "26.05";

          environment.systemPackages = [ pkgs.ghostty.terminfo ];
        }
      )
    ];
  };

  # `nix build .#sdImage-ftomi-rpi` — same config that runs on the device.
  flake.packages.aarch64-linux.sdImage-ftomi-rpi =
    config.flake.nixosConfigurations.ftomi-rpi.config.system.build.sdImage;
}
