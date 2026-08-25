{
  flake.modules.homeManager.zed = {
    programs.zed-editor = {
      enable = true;
      userSettings = {
        languages.Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
          formatter.external = {
            command = "nixfmt";
            arguments = [
              "--quiet"
              "--"
            ];
          };
        };
      };
    };

    wayland.windowManager.niri.settings.binds."Mod+Z".spawn = [ "zeditor" ];
  };
}
