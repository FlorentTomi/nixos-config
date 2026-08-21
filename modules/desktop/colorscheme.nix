{
  homeManager.modules.colorscheme =
    {
      inputs,
      lib,
      config,
      ...
    }:
    let
      hexDigit =
        c:
        {
          "0" = 0;
          "1" = 1;
          "2" = 2;
          "3" = 3;
          "4" = 4;
          "5" = 5;
          "6" = 6;
          "7" = 7;
          "8" = 8;
          "9" = 9;
          "a" = 10;
          "b" = 11;
          "c" = 12;
          "d" = 13;
          "e" = 14;
          "f" = 15;
        }
        .${lib.toLower c};

      hexByte = s: (hexDigit (lib.substring 0 1 s)) * 16 + (hexDigit (lib.substring 1 1 s));

      rgbOf =
        hex:
        "${toString (hexByte (lib.substring 0 2 hex))}, ${toString (hexByte (lib.substring 2 2 hex))}, ${
          toString (hexByte (lib.substring 4 2 hex))
        }";

      p = config.colorScheme.palette;

      themePalette = {
        background = p.base00;
        backgroundPanel = p.base01;
        selection = p.base02;
        muted = p.base03;
        foregroundDim = p.base04;
        foreground = p.base05;
        foregroundBright = p.base06;
        backgroundBright = p.base07;

        red = p.base08;
        orange = p.base09;
        yellow = p.base0A;
        green = p.base0B;
        cyan = p.base0C;
        blue = p.base0D;
        accent = p.base0E;
        brown = p.base0F;
      };

      cssPalette =
        (lib.mapAttrs (_: hex: "#${hex}") themePalette)
        // (lib.mapAttrs' (name: hex: lib.nameValuePair "${name}-rgb" (rgbOf hex)) themePalette);

      substitute =
        pattern: text: extra:
        let
          tokens = cssPalette // extra;
          names = lib.sort (a: b: lib.stringLength a > lib.stringLength b) (builtins.attrNames tokens);
        in
        builtins.replaceStrings (map pattern names) (map (n: tokens.${n}) names) text;
    in
    {
      imports = [ inputs.nix-colors.homeManagerModules.default ];

      colorScheme = inputs.nix-colors.colorSchemes.catppuccin-macchiato;      

      _module.args = {
        inherit themePalette;
        themeRgb = rgbOf;
        themeCss =
          {
            text,
            extra ? { },
          }:
          substitute (n: "@@${n}@@") text extra;
        themeScss = (
          {
            text,
            extra ? { },
          }:
          substitute (n: "\$${n}") text extra
        );
      };
    };
}
