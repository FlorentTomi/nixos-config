{
  flake.modules.homeManager.fuzzel =
    { themePalette, ... }:
    let
      colorPalette = {
        bg = "${themePalette.background}";
        bgAlt = "${themePalette.background-alt}";
        surface = "${themePalette.background-selection}";
        border = "${themePalette.popup.border-low-urgency}";
        fg = "${themePalette.text}";
        fgMuted = "${themePalette.popup.border-low-urgency}";
        accent = "${themePalette.accent}";
        accent1 = "${themePalette.accent}";
        accent2 = "${themePalette.image.orange}";
        accent3 = "${themePalette.image.green}";
        accent4 = "${themePalette.image.cyan}";
        accent5 = "${themePalette.image.cyan}";
        accent6 = "${themePalette.image.purple}";
        accent7 = "${themePalette.image.purple}";
        warning = "${themePalette.image.yellow}";
        danger = "${themePalette.image.red}";
        pillBg = "${colorPalette.accent}";
        onAccent = "${colorPalette.bg}";
      };

    in
    {
      stylix.targets.fuzzel.enable = false;
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = "JetBrains Mono:size=11";
            line-height = 22;
            letter-spacing = 0;
            width = 48;
            lines = 12;
            horizontal-pad = 16;
            vertical-pad = 14;
            inner-pad = 10;
            prompt = "'> '";
            icon-theme = "Papirus-Dark";
            icons-enabled = true;
            fields = "name,generic";
            counter = true;
            layer = "overlay";
            terminal = "ghostty -e";
          };

          colors = {
            background = "${colorPalette.bg}f2";
            text = "${colorPalette.fgMuted}ff";
            prompt = "${colorPalette.accent6}ff";
            placeholder = "${colorPalette.fgMuted}ff";
            input = "${colorPalette.fg}ff";
            match = "${colorPalette.accent6}ff";
            selection = "${colorPalette.surface}ff";
            selection-text = "${colorPalette.fg}ff";
            selection-match = "${colorPalette.accent6}ff";
            counter = "${colorPalette.fgMuted}ff";
            border = "${colorPalette.border}ff";
          };

          border = {
            width = 1;
            radius = 0;
          };

          dmenu.exit-immediately-if-empty = true;
        };
      };

      wayland.windowManager.niri.settings.binds = {
        "Mod+Space".spawn = [ "fuzzel" ];
      };
    };
}
