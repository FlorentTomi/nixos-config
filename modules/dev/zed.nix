{
  flake.modules.homeManager.zed = {
    programs.zed-editor.enable = true;

    wayland.windowManager.niri.settings.binds."Mod+Z".spawn = [ "zeditor" ];
  };
}
