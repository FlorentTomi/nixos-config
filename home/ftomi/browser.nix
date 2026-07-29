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

  # Floorp's picture-in-picture window shouldn't get tiled like a normal window.
  programs.niri.settings.window-rules = [
    {
      matches = [
        {
          app-id = "floorp$";
          title = "^Picture-in-Picture$";
        }
      ];
      open-floating = true;
    }
  ];
}
