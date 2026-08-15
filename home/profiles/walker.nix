{
  inputs,
  catppuccinPalette,
  catppuccinRgb,
  ...
}:
let
  p = catppuccinPalette;
  rgb = catppuccinRgb;

  bgAlpha = "0.95";
in
{
  imports = [ inputs.walker.homeManagerModules.default ];

  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      theme = "custom";

      placeholders."default" = {
        input = "Search";
        list = "No results";
      };

      providers.prefixes = [
        {
          provider = "files";
          prefix = "/";
        }
        {
          provider = "calc";
          prefix = "=";
        }
        {
          provider = "clipboard";
          prefix = ":";
        }
        {
          provider = "symbols";
          prefix = ".";
        }
        {
          provider = "websearch";
          prefix = "+";
        }
        {
          provider = "providerlist";
          prefix = ";";
        }
      ];
    };

    themes.custom = {
      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font";
          font-size: 10pt;
          color: #${p.text};
        }

        window,
        .background {
          /* This node is the whole-monitor layer-shell surface, not the
             visible menu box — confirmed by it going fullscreen once
             this actually had a background-color. .box-wrapper below is
             the real 600x550 centered box (see layout.xml); that's
             where the visible chrome belongs. */
          background-color: transparent;
        }

        .box-wrapper {
          background-color: rgba(${rgb "base"}, ${bgAlpha});
          border-radius: 15px;
          border: 1px solid rgba(${rgb "overlay0"}, 0.4);
          padding: 20px;
        }

        entry {
          background-color: rgba(${rgb "surface0"}, ${bgAlpha});
          border-radius: 10px;
          padding: 15px;
          color: #${p.text};
          caret-color: #${p.blue};
        }

        entry placeholder {
          color: #${p.subtext1};
        }

        .error {
          color: #${p.red};
        }

        /* New: the logo added in layouts.layout below. */
        .logo {
          margin-right: 4px;
        }

        .scroll {
          background-color: transparent;
        }

        .list {
          background-color: transparent;
        }

        row {
          border-radius: 10px;
          padding: 8px;
          margin-bottom: 10px;
          color: #${p.text};
        }

        row:hover {
          background-color: rgba(${rgb "surface0"}, ${bgAlpha});
        }

        row:selected {
          background-color: #${p.blue};
          color: #${p.mantle};
        }

        image {
          -gtk-icon-size: 32px;
        }

        scrollbar {
          background-color: transparent;
        }
      '';
    };
  };

  wayland.windowManager.niri.settings.binds = {
    "Mod+Space".spawn = [ "walker" ];
  };
}
