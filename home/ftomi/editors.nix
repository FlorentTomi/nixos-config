{ pkgs, ... }:

{
  programs.zed-editor.enable = true;
  programs.vscode.enable = true;

  home.packages = [
    pkgs.gimp
    pkgs.inkscape
  ];

  programs.niri.settings.binds."Mod+Z".action.spawn = "zeditor";
}
