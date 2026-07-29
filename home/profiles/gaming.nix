{ pkgs, ... }:

{
  programs.lutris.enable = true;

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

  programs.niri.settings.window-rules = [
    {
      matches = [
        { app-id = "^steam_app_.*$"; }
      ];
      open-maximized = true;
    }
  ];
}
