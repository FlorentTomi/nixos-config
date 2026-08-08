{ pkgs, ... }:

{
  programs.lutris.enable = true;
  programs.prismlauncher.enable = true;

  programs.mangohud = {
    enable = true;
    settings = {
      fps_limit = 0;
      gpu_stats = true;
      cpu_stats = true;
      frame_timing = true;
    };
  };

  home.packages = [
    pkgs.heroic
    pkgs.protonup-qt
    pkgs.moonlight-qt
  ];

  wayland.windowManager.niri.settings._children = [
    {
      window-rule._children = [
        { match._props.app-id = "^steam_app_.*$"; }
        { open-maximized = true; }
      ];
    }
  ];
}
