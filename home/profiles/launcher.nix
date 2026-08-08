{
  config,
  osConfig,
  lib,
  pkgs,
  catppuccinRgb,
  ...
}:
let
  vpnNames = import ./resources/vpn-names.nix { inherit osConfig; };
  rofiVpnScript = import ./resources/vpn-select.nix { inherit lib pkgs vpnNames; };

  inherit (config.lib.formats.rasi) mkLiteral;

  # catppuccinRgb (home/ftomi/theme.nix) reads decimal RGB straight out of
  # the catppuccin/palette package's JSON by color name — no hex
  # intermediate, no hand-typed decimal table.
  mkRgba = opacity': color: "rgba ( ${catppuccinRgb color}, ${opacity'} % )";
  mkRgb = mkRgba "100";
  # Was config.stylix.opacity.popups * 100 — no direct catppuccin/nix
  # equivalent (opacity isn't part of a color scheme), so picked a sensible
  # near-opaque default by hand. Adjust to taste.
  rofiOpacity = "95";
  # Was config.stylix.targets.rofi.alternatePattern — a Stylix-specific
  # concept with no equivalent elsewhere. Must be `true`, not just a stylistic
  # choice: every `alternate-*` property below builds on a `base` argument
  # that's already `mkLiteral`-wrapped (e.g. `active-background`), and
  # `mkAlternate` wraps its result in `mkLiteral` again at each call site —
  # if `alternatePattern` is `false`, `mkAlternate` returns that
  # already-wrapped `base` unchanged, and the outer `mkLiteral` wraps it a
  # second time, which home-manager's rofi module rejects (nested `.value`
  # isn't a string). `true` makes `mkAlternate` return the plain-string
  # `alternate` argument instead, avoiding the double-wrap — this is almost
  # certainly what Stylix's real value was, since the bug would otherwise
  # have shown up under the old setup too.
  alternatePattern = true;
  mkAlternate = base: alternate: if alternatePattern then alternate else base;

  c = rec {
    background = mkLiteral (mkRgba rofiOpacity "base");
    lightbg = mkLiteral (mkRgba rofiOpacity "mantle");
    red = mkLiteral (mkRgba rofiOpacity "red");
    blue = mkLiteral (mkRgba rofiOpacity "blue");
    lightfg = mkLiteral (mkRgba rofiOpacity "subtext1");
    foreground = mkLiteral (mkRgba rofiOpacity "text");
    background-color = mkLiteral (mkRgb "base");
    background-alt = mkLiteral (mkRgba rofiOpacity "surface0");
    selected = mkLiteral "@blue";
    active = mkLiteral "@blue";
    urgent = mkLiteral "@red";

    normal-foreground = c.foreground;
    normal-background = mkLiteral "@background";
    active-foreground = mkLiteral "@blue";
    active-background = mkLiteral "@background";
    urgent-foreground = mkLiteral "@red";
    urgent-background = mkLiteral "@background";

    alternate-normal-foreground = mkLiteral (mkAlternate normal-foreground "@foreground");
    alternate-normal-background = mkLiteral (mkAlternate normal-background "@lightbg");
    alternate-active-foreground = mkLiteral (mkAlternate active-foreground "@blue");
    alternate-active-background = mkLiteral (mkAlternate active-background "@lightbg");
    alternate-urgent-foreground = mkLiteral (mkAlternate urgent-foreground "@red");
    alternate-urgent-background = mkLiteral (mkAlternate urgent-background "@lightbg");

    base-text = mkLiteral (mkRgb "text");
    selected-normal-text = mkLiteral (mkRgb "mantle");
    selected-active-text = mkLiteral (mkRgb "base");
    selected-urgent-text = mkLiteral (mkRgb "base");
    normal-text = mkLiteral (mkRgb "text");
    active-text = mkLiteral (mkRgb "blue");
    urgent-text = mkLiteral (mkRgb "red");
    alternate-normal-text = mkLiteral (mkAlternate normal-text (mkRgb "text"));
    alternate-active-text = mkLiteral (mkAlternate active-text (mkRgb "blue"));
    alternate-urgent-text = mkLiteral (mkAlternate urgent-text (mkRgb "red"));
  };
in
{

  home.packages = [
    pkgs.papirus-icon-theme
    rofiVpnScript
  ];

  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun,window,ssh,vpn:${rofiVpnScript}/bin/vpn-select";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      me-select-entry = "";
      me-accept-entry = "MousePrimary";

      display-drun = "Applications";
      drun-display-format = "{name}";

      display-window = "Windows";
      window-format = "{w} · {c} · {t}";

      display-vpn = "VPN";

      display-ssh = "SSH";
      parse-known-hosts = false;
    };
    font = "JetBrains Mono Nerd Font 10";
    theme = {
      "*" = {
        background = c.background;
        lightbg = c.lightbg;
        red = c.red;
        blue = c.blue;
        lightfg = c.lightfg;
        foreground = c.foreground;

        background-color = c.background-color;
        background-alt = c.background-alt;
        selected = c.selected;
        active = c.active;
        urgent = c.urgent;
        separatorcolor = c.foreground;
        border-color = c.foreground;
        selected-normal-foreground = mkLiteral "@lightbg";
        selected-normal-background = mkLiteral "@lightfg";
        selected-active-foreground = mkLiteral "@background";
        selected-active-background = mkLiteral "@blue";
        selected-urgent-foreground = mkLiteral "@background";
        selected-urgent-background = mkLiteral "@red";
        normal-foreground = c.foreground;
        normal-background = mkLiteral "@background";
        active-foreground = mkLiteral "@blue";
        active-background = mkLiteral "@background";
        urgent-foreground = mkLiteral "@red";
        urgent-background = mkLiteral "@background";
        alternate-normal-foreground = c.alternate-normal-foreground;
        alternate-normal-background = c.alternate-normal-background;
        alternate-active-foreground = c.alternate-active-foreground;
        alternate-active-background = c.alternate-active-background;
        alternate-urgent-foreground = c.alternate-urgent-foreground;
        alternate-urgent-background = c.alternate-urgent-background;

        base-text = c.base-text;
        selected-normal-text = c.selected-normal-text;
        selected-active-text = c.selected-active-text;
        selected-urgent-text = c.selected-urgent-text;
        normal-text = c.normal-text;
        active-text = c.active-text;
        urgent-text = c.urgent-text;
        alternate-normal-text = c.alternate-normal-text;
        alternate-active-text = c.alternate-active-text;
        alternate-urgent-text = c.alternate-urgent-text;
      };

      window = {
        transparency = "real";
        location = mkLiteral "center";
        anchor = mkLiteral "center";
        fullscreen = false;
        width = mkLiteral "1000px";
        x-offset = mkLiteral "0px";
        y-offset = mkLiteral "0px";

        enabled = true;
        border-radius = mkLiteral "15px";
        cursor = mkLiteral "default";
        background-color = mkLiteral "@background";
      };

      mainbox = {
        enabled = true;
        spacing = mkLiteral "0px";
        background-color = mkLiteral "transparent";
        orientation = mkLiteral "horizontal";
        children = [
          "imagebox"
          "listbox"
        ];
      };

      imagebox = {
        padding = mkLiteral "20px";
        background-color = mkLiteral "transparent";
        orientation = mkLiteral "vertical";
        children = [
          "inputbar"
          "logo-row"
          "mode-switcher"
        ];
      };

      listbox = {
        spacing = mkLiteral "20px";
        padding = mkLiteral "20px";
        background-color = mkLiteral "transparent";
        orientation = mkLiteral "vertical";
        children = [
          "message"
          "listview"
        ];
      };

      logo-row = {
        background-color = mkLiteral "transparent";
        orientation = mkLiteral "horizontal";
        children = [
          "logo-filler-left"
          "icon-logo"
          "logo-filler-right"
        ];
      };

      logo-filler-left = {
        expand = true;
        background-color = mkLiteral "transparent";
      };

      logo-filler-right = {
        expand = true;
        background-color = mkLiteral "transparent";
      };

      icon-logo = {
        expand = false;
        filename = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        size = mkLiteral "220";
        vertical-align = mkLiteral "0.5";
      };

      inputbar = {
        enabled = true;
        spacing = mkLiteral "10px";
        padding = mkLiteral "15px";
        border-radius = mkLiteral "10px";
        background-color = mkLiteral "@background-alt";
        text-color = c.foreground;
        children = [
          "textbox-prompt-colon"
          "entry"
        ];
      };

      textbox-prompt-colon = {
        enabled = true;
        expand = false;
        str = "";
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      entry = {
        enabled = true;
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
        cursor = mkLiteral "text";
        placeholder = "Search";
        placeholder-color = mkLiteral "inherit";
      };

      mode-switcher = {
        enabled = true;
        spacing = mkLiteral "20px";
        background-color = mkLiteral "transparent";
        text-color = c.foreground;
      };

      button = {
        padding = mkLiteral "15px";
        border-radius = mkLiteral "10px";
        background-color = mkLiteral "@background-alt";
        text-color = mkLiteral "inherit";
        cursor = mkLiteral "pointer";
      };

      "button selected" = {
        background-color = mkLiteral "@selected";
        text-color = mkLiteral "@selected-normal-text";
      };

      listview = {
        enabled = true;
        columns = 1;
        lines = 8;
        cycle = true;
        dynamic = true;
        scrollbar = false;
        layout = mkLiteral "vertical";
        reverse = false;
        fixed-height = true;
        fixed-columns = true;
        # rofi's built-in default theme applies a dashed separator to
        # listview when nothing overrides it explicitly — the dotted line
        # visible at the top of the results panel. Predates this migration
        # (this file never set it, under Stylix or otherwise); explicitly
        # disabled now that it's been noticed.
        border = mkLiteral "0px";

        spacing = mkLiteral "10px";
        background-color = mkLiteral "transparent";
        text-color = c.foreground;
        cursor = mkLiteral "default";
      };

      element = {
        enabled = true;
        spacing = mkLiteral "15px";
        padding = mkLiteral "8px";
        border-radius = mkLiteral "10px";
        background-color = mkLiteral "transparent";
        text-color = c.foreground;
        cursor = mkLiteral "pointer";
      };

      "element normal.normal" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      "element normal.urgent" = {
        background-color = mkLiteral "@urgent";
        text-color = c.foreground;
      };

      "element normal.active" = {
        background-color = mkLiteral "@active";
        text-color = c.foreground;
      };

      "element selected.normal" = {
        background-color = mkLiteral "@selected";
        text-color = mkLiteral "@selected-normal-text";
      };

      "element selected.urgent" = {
        background-color = mkLiteral "@urgent";
        text-color = c.foreground;
      };

      "element selected.active" = {
        background-color = mkLiteral "@active";
        text-color = mkLiteral "@selected-active-text";
      };

      element-icon = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        size = mkLiteral "32px";
        cursor = mkLiteral "inherit";
      };

      element-text = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        cursor = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.0";
      };

      message = {
        background-color = mkLiteral "transparent";
      };

      textbox = {
        padding = mkLiteral "15px";
        border-radius = mkLiteral "10px";
        background-color = mkLiteral "@background-alt";
        text-color = c.foreground;
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.0";
      };

      error-message = {
        padding = mkLiteral "15px";
        border-radius = mkLiteral "20px";
        background-color = mkLiteral "@background";
        text-color = c.foreground;
      };
    };
  };

  wayland.windowManager.niri.settings.binds."Mod+Space".spawn = [
    "rofi"
    "-show"
    "drun"
  ];
}
