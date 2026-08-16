{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  flavor = "macchiato";
  accent = "mauve";

  system = pkgs.stdenv.hostPlatform.system;

  paletteData = builtins.fromJSON (
    builtins.readFile "${inputs.catppuccin.packages.${system}.palette}/palette.json"
  );
  flavorColors = paletteData.${flavor}.colors;

  # Hex, without the leading '#' — e.g. palette.blue -> "89b4fa" — matching
  # what niri-core.nix/waybar.nix/launcher.nix already expect.
  palette = lib.mapAttrs (_name: c: lib.removePrefix "#" c.hex) flavorColors;
  cssPaletteRgb = lib.mapAttrs' (name: _: lib.nameValuePair "${name}-rgb" (rgbOf name)) flavorColors;
  cssPalette = (lib.mapAttrs (_name: hex: "#${hex}") palette) // cssPaletteRgb;


  # Decimal "r, g, b" for a color name, read directly from the same JSON
  # (it ships pre-computed decimal RGB, so no hex-parsing needed on our
  # side at all) — used by rofi's rgba() syntax.
  rgbOf =
    name:
    let
      c = flavorColors.${name}.rgb;
    in
    "${toString c.r}, ${toString c.g}, ${toString c.b}";
in
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  _module.args = {
    catppuccinPalette = palette;
    catppuccinRgb = rgbOf;
    catppuccinCss =
      {
        text,
        extra ? { },
      }:
      let
        tokens = cssPalette // extra;
        names = builtins.attrNames tokens;
      in
      builtins.replaceStrings (map (n: "@@${n}@@") names) (map (n: tokens.${n}) names) text;
  };

  catppuccin = {
    autoEnable = true;
    enable = true;
    inherit flavor accent;

    cache.enable = true;

    gtk.icon.enable = true;
    fuzzel.enable = true;
    hyprlock = {
      enable = true;
      useDefaultConfig = false;
    };
    waybar.enable = true;
    starship.enable = false;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ accent ];
        variant = flavor;
        size = "standard";
      };
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    accent-color = "purple";
    gtk-theme = "Catppuccin-Mocha-Standard-Mauve-Dark";
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "JetBrainsMono Nerd Font" ];
      serif = [ "JetBrainsMono Nerd Font" ];
    };
  };

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
