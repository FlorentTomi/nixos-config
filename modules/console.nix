{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.console;
in
{
  options.modules.console = {
    enable = lib.mkEnableOption "large fullscreen TTY console for use with Ly";

    backend = lib.mkOption {
      type = lib.types.enum [
        "fbcon"
        "kmscon"
      ];
      default = "fbcon";
      description = "fbcon = kernel console via nvidia_drm.fbdev. kmscon = userspace DRM console (fallback if fbcon misbehaves).";
    };

    # Common resolution forced on BOTH outputs so the console clones fullscreen
    # on each monitor instead of picking one native mode and leaving the other
    # dark/cropped. 1920x1080 is the shared denominator between your 4K DP-1
    # and 1080p HDMI-A-1 — DP-1 will just upscale/blurry-render it, which is fine.
    resolution = lib.mkOption {
      type = lib.types.str;
      default = "1920x1080";
    };

    # Terminus only ships specific sizes: 12,14,16,18,20,22,24,28,32
    fontSize = lib.mkOption {
      type = lib.types.ints.between 12 32;
      default = 32;
    };

    outputs = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        "DP-1" = "3840x2160";
        "HDMI-A-1" = "1920x1080";
      };
      description = "Connector -> resolution map, forced via video= kernel params. Use each monitor's NATIVE mode so fbcon fills the panel instead of getting letterboxed by non-native scaling.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { boot.loader.limine.resolution = cfg.resolution; }

      (lib.mkIf (cfg.backend == "fbcon") {
        boot.kernelParams = [
          "fbcon=nodefer"
        ]
        ++ lib.mapAttrsToList (name: res: "video=${name}:${res}@60") cfg.outputs;

        console = {
          earlySetup = true;
          packages = [ pkgs.terminus_font ];
          font = "${pkgs.terminus_font}/share/consolefonts/ter-v${toString cfg.fontSize}n.psf.gz";
        };
      })

      (lib.mkIf (cfg.backend == "kmscon") {
        boot.kernelParams = lib.mkForce [
          "nvidia-drm.modeset=1"
          "nvidia-drm.fbdev=0"
        ];

        fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
        fonts.fontconfig.enable = true;
        hardware.graphics.enable = true;

        services.kmscon = {
          enable = true;
          useXkbConfig = true;
          config = {
            hwaccel = true;
            font-size = lib.mkForce cfg.fontSize;
          };
        };
      })
    ]
  );
}
