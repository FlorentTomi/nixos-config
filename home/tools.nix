{ pkgs, ... }:

{
  programs.discord.enable = true;

  home.packages = [
    pkgs.scrcpy
    pkgs.android-tools
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

  services = {
    tailscale-systray.enable = true;
  };
}
