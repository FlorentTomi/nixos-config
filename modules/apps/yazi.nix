{
  flake.modules.homeManager.yazi =
    { inputs, pkgs, ... }:
    {
      programs.yazi = {
        enable = true;
        enableFishIntegration = true;

        plugins = {
          mount = "${inputs.yazi-plugins}/mount.yazi";
          git = "${inputs.yazi-plugins}/git.yazi";
        };

        initLua = ''
             require("git"):setup {
          	    -- Order of status signs showing in the linemode
              	order = 1500,
             }
        '';

        settings = {
          plugin.prepend_fetchers = [
            {
              url = "*";
              run = "git";
              group = "git";
            }
            {
              url = "*/";
              run = "git";
              group = "git";
            }
          ];
        };

        keymap = {
          mgr.prepend_keymap = [
            {
              on = [ "M" ];
              run = "plugin mount";
              desc = "Mount/unmount devices";
            }
          ];
        };
      };

      wayland.windowManager.niri.settings.binds."Mod+E".spawn = [
        "ghostty"
        "--confirm-close-surface=false"
        "-e"
        "yazi"
      ];

      home.packages = with pkgs; [
        ffmpegthumbnailer # video thumbnails
        ffmpeg # video metadata/processing
        poppler # pdf previews
        imagemagick # image previews/conversion
        unar # archive previews (zip, rar, 7z etc.)
        jq # json previews
        fd # fast file finder, used by yazi's search
        ripgrep # used for file content search
        fzf # fuzzy finder integration
      ];
    };
}
