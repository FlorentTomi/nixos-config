{
  flake.modules.homeManager.nirimon =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nirimon ];
      wayland.windowManager.niri.settings.binds."Mod+P".spawn = [
        "ghostty"
        "--confirm-close-surface=false"
        "-e"
        "nirimon"
      ];
    };
}
