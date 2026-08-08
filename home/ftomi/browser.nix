{ pkgs, ... }:

{
  home.packages = [
    pkgs.floorp-bin
    pkgs.ungoogled-chromium
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "floorp.desktop";
      "x-scheme-handler/http" = "floorp.desktop";
      "x-scheme-handler/https" = "floorp.desktop";
      "x-scheme-handler/about" = "floorp.desktop";
      "x-scheme-handler/unknown" = "floorp.desktop";
      "application/pdf" = "floorp.desktop";
    };
  };

  # Floorp's picture-in-picture window shouldn't get tiled like a normal
  # window. wayland.windowManager.niri.settings is freeform/generic KDL, not
  # niri-flake's typed schema — a repeated top-level `window-rule { }` node
  # has to go through the root-level `_children` list (see also gaming.nix,
  # which contributes its own window-rule the same way; NixOS's module
  # merge concatenates both files' `_children` lists into one).
  wayland.windowManager.niri.settings._children = [
    {
      window-rule._children = [
        {
          match._props = {
            app-id = "floorp$";
            title = "^Picture-in-Picture$";
          };
        }
        { open-floating = true; }
      ];
    }
  ];

  wayland.windowManager.niri.settings.binds."Mod+B".spawn = [ "floorp" ];
}
