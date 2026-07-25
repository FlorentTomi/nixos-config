{ config, lib, inputs, ... }:
let
  cfg = config.modules.niri;
in
{
  imports = [ inputs.niri.nixosModules.niri ];

  options.modules.niri.enable = lib.mkEnableOption "niri window manager";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    niri-flake.cache.enable = false;

    nixpkgs.overlays = [ inputs.niri.overlays.niri ];

    xdg.portal.config.niri = {
      default = [
        "gnome"
        "wlr"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };
}
