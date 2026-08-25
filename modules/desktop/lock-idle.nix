{
  flake.modules.homeManager.lock-idle = {
    programs.hyprlock = {
      enable = true;
      extraConfig = builtins.readFile ../../resources/hyprlock-config.conf;
    };

    wayland.windowManager.niri.settings.binds."Mod+L".spawn = [ "hyprlock" ];

    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 300;
          command = "hyprlock";
        }
        {
          timeout = 600;
          command = "niri msg action power-off-monitors";
          resumeCommand = "niri msg action power-on-monitors";
        }
      ];
      events = {
        before-sleep = "hyprlock";
        lock = "hyprlock";
      };
    };
  };
}
