{
  flake.modules.homeManager.rio =
    {
      lib,
      ...
    }:
    {
      programs.rio = {
        enable = true;
        settings = {
          enable-scroll-bar = true;
          confirm-before-quit = false;
          effects.trail-cursor = true;
          window.opacity = lib.mkForce 0.9;
          window.blur = true;
        };
      };

      wayland.windowManager.niri.settings.binds."Mod+Return".spawn = [ "rio" ];
    };
}
