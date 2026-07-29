{ ... }:
{
  programs.fuzzel.enable = true;
  programs.niri.settings.binds."Mod+Space".action.spawn = "fuzzel";
}
