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
  ];
}
