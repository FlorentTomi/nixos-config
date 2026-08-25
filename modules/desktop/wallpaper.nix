{
  flake.modules.homeManager.wallpaper =
    {
      pkgs,
      config,
      ...
    }:
    let
      home-relative-wallpapers = "Pictures/Wallpapers";
      wrapped-waypaper = pkgs.symlinkJoin {
        name = "waypaper";
        paths = [ pkgs.waypaper ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/waypaper \
            --add-flags "--folder ${config.home.homeDirectory}/${home-relative-wallpapers}"
        '';
      };
    in
    {
      services.awww.enable = true;
      home.packages = [ wrapped-waypaper ];

      home.file."${home-relative-wallpapers}" = {
        source = ../../resources/wallpapers;
        recursive = true;
      };

      wayland.windowManager.niri.settings._children = [
        {
          spawn-at-startup._args = [
            "waypaper"
            "--restore"
          ];
        }
      ];
    };
}
