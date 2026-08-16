{ pkgs, ... }:

{
  programs.zed-editor.enable = true;
  programs.vscode.enable = true;

  programs.joplin-desktop = {
    enable = true;
    sync.target = "none";
  };

  home.packages = [
    pkgs.gimp
    pkgs.inkscape
    pkgs.onlyoffice-desktopeditors
  ];

  wayland.windowManager.niri.settings.binds."Mod+Z".spawn = [ "zeditor" ];
}
