{ ... }:

{
  programs.zed-editor.enable = true;
  programs.niri.settings.binds."Mod+Z".action.spawn = "zeditor";

  programs.vscode.enable = true;
}
