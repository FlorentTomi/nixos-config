# Single source of truth for per-user theming — colors, cursor, fonts.
# Previously provided system-wide by Stylix (profiles/ftomi/stylix.nix,
# NixOS-level); scoped entirely to this user's home-manager config now.
# Deliberate trade-off: boot splash, console, and the ly greeter are no
# longer themed, since nothing outside a logged-in session needs it.
{ pkgs, lib, inputs, ... }:
let
  # The only two knobs you should ever need to touch to change the whole
  # desktop's theme. `flavor` drives both catppuccin/nix's own per-app
  # modules (gtk/fuzzel/hyprlock/waybar, below) AND the raw palette data
  # read from the actual catppuccin/palette package — so switching flavors
  # here changes everything consistently, not just the auto-themed apps.
  flavor = "mocha";
  accent = "mauve";

  system = pkgs.stdenv.hostPlatform.system;

  # Reads the real, canonical palette straight from the catppuccin/palette
  # package (github.com/catppuccin/palette) that catppuccin/nix itself
  # builds from — no hand-typed color values anywhere in this repo. This
  # is import-from-derivation (IFD): Nix builds this small package during
  # evaluation, not just at system-build time, which means the first
  # `nh os build` after a flake update needs network access a moment
  # earlier than usual. Traded deliberately for zero risk of this repo's
  # colors ever drifting from the actual published palette.
  paletteData = builtins.fromJSON (
    builtins.readFile "${inputs.catppuccin.packages.${system}.palette}/palette.json"
  );
  flavorColors = paletteData.${flavor}.colors;

  # Hex, without the leading '#' — e.g. palette.blue -> "89b4fa" — matching
  # what niri-core.nix/waybar.nix/launcher.nix already expect.
  palette = lib.mapAttrs (_name: c: lib.removePrefix "#" c.hex) flavorColors;

  # Decimal "r, g, b" for a color name, read directly from the same JSON
  # (it ships pre-computed decimal RGB, so no hex-parsing needed on our
  # side at all) — used by rofi's rgba() syntax.
  rgbOf = name: let c = flavorColors.${name}.rgb; in "${toString c.r}, ${toString c.g}, ${toString c.b}";
in
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  # Available in every other home-manager module for this user, the same
  # way pkgs/lib/config already are:
  #   catppuccinPalette.mauve   -> "cba6f7"
  #   catppuccinRgb "base"      -> "30, 30, 46"
  _module.args = {
    catppuccinPalette = palette;
    catppuccinRgb = rgbOf;
  };

  catppuccin = {
    enable = true;
    inherit flavor accent;

    # catppuccin/nix builds some ports (including waybar's) with whiskers,
    # its own Rust templating tool, compiled from source by default. Their
    # own release notes flag this explicitly as a reason to turn this on.
    # Without it, a from-source whiskers build can hit real upstream rustc
    # bugs (an actual Internal Compiler Error under LTO while compiling
    # `memchr`, encountered while setting this up) that have nothing to do
    # with anything in this repo. This writes extra-substituters /
    # extra-trusted-public-keys into this user's own nix.conf — works
    # without any NixOS-level change as long as this user is a trusted Nix
    # user (true by default for the primary user on most personal
    # single-user NixOS installs).
    cache.enable = true;

    # These had no hand-written theming of their own — they were purely
    # auto-themed by Stylix before, so catppuccin/nix's equivalent per-app
    # modules are a direct, low-risk swap. gtk.icon (not gtk.enable, which
    # doesn't exist — catppuccin/nix's GTK module only offers icon theming;
    # modern GTK4/libadwaita apps like Nautilus don't support arbitrary
    # widget-level custom themes the way GTK3 apps used to, only
    # light/dark + accent color, which libadwaita already reads from the
    # desktop) covers the icon set used by Nautilus, niri's portal
    # FileChooser backend.
    #
    # waybar is NOT enabled here — its stylesheet is built explicitly in
    # home/profiles/waybar.nix instead, reading config.catppuccin.sources
    # directly, rather than depending on catppuccin.waybar.enable's own
    # mkBefore injection composing correctly with our mkAfter contribution
    # across two separate modules into the same (nullOr (either path
    # lines))-typed `style` option — one fewer moving part to reason about.
    gtk.icon.enable = true;
    fuzzel.enable = true;
    hyprlock.enable = true;
    waybar.enable = true;
  };

  # Bibata isn't a Catppuccin-branded cursor set — it's an independent
  # choice Stylix's `cursor` option happened to let us plug in alongside
  # the color scheme. home-manager's own `home.pointerCursor` is the
  # correct, framework-independent way to set it now.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
  };

  # Stylix used to apply this as a system-wide fontconfig default, which is
  # how apps like waybar picked up the right font without any per-app
  # config. Replicated here at the user level via home-manager's own
  # fontconfig option, so nothing needs explicit font-family wiring beyond
  # what already existed (e.g. launcher.nix's rofi, which hardcoded its own
  # font independently of Stylix from the start).
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "JetBrainsMono Nerd Font" ];
      serif = [ "JetBrainsMono Nerd Font" ];
    };
  };

  home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
