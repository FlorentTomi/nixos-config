{ pkgs, ... }:

{
  programs.zed-editor.enable = true;
  programs.vscode.enable = true;

  home.packages = [
    pkgs.gimp
    pkgs.inkscape
  ];

  wayland.windowManager.niri.settings.binds."Mod+Z".spawn = [ "zeditor" ];
}
