{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  stylix-color = config.lib.stylix.colors;
  stylix-opacity = config.stylix.opacity;
  alternatePattern = config.stylix.targets.rofi.alternatePattern;

  # osConfig's own VPN list (modules/openvpn.nix), not a systemctl unit-name
  # glob: services.openvpn also creates its own internal units matching
  # "openvpn-*" (e.g. openvpn-restart.service, a sleep/resume hook) that
  # aren't actual VPNs and would otherwise leak into the menu. Same lookup
  # as home/profiles/shell.nix's fish completions.
  vpnNames = map (c: c.name) osConfig.modules.openvpn.configs;

  # rofi script-mode backend for the VPN menu below.
  rofiVpnScript = pkgs.writeShellApplication {
    name = "rofi-vpn";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      vpns=(${lib.concatStringsSep " " vpnNames})

      # Rofi calls a script-mode backend a second time with the selected
      # line as $1 when the user hits enter on an entry.
      if [[ -n "''${1-}" ]]; then
        name="''${1%% *}"
        if systemctl is-active --quiet "openvpn-$name"; then
          systemctl stop "openvpn-$name"
        else
          systemctl start "openvpn-$name"
        fi
      fi

      for name in "''${vpns[@]}"; do
        if systemctl is-active --quiet "openvpn-$name"; then
          echo "$name (on)"
        else
          echo "$name (off)"
        fi
      done
    '';
  };

  inherit (config.lib.formats.rasi) mkLiteral;

  mkRgba =
    opacity': color:
    let
      r = stylix-color."${color}-rgb-r";
      g = stylix-color."${color}-rgb-g";
      b = stylix-color."${color}-rgb-b";
    in
    "rgba ( ${r}, ${g}, ${b}, ${opacity'} % )";
  mkRgb = mkRgba "100";
  rofiOpacity = toString (builtins.ceil (stylix-opacity.popups * 100));
  mkAlternate = base: alternate: if alternatePattern then alternate else base;

  c = rec {
    background = mkLiteral (mkRgba rofiOpacity "base00");
    lightbg = mkLiteral (mkRgba rofiOpacity "base01");
    red = mkLiteral (mkRgba rofiOpacity "base08");
    blue = mkLiteral (mkRgba rofiOpacity "base0D");
    lightfg = mkLiteral (mkRgba rofiOpacity "base06");
    foreground = mkLiteral (mkRgba rofiOpacity "base05");
    background-color = mkLiteral (mkRgb "base00");
    background-alt = mkLiteral (mkRgba rofiOpacity "base02");
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

    base-text = mkLiteral (mkRgb "base05");
    selected-normal-text = mkLiteral (mkRgb "base01");
    selected-active-text = mkLiteral (mkRgb "base00");
    selected-urgent-text = mkLiteral (mkRgb "base00");
    normal-text = mkLiteral (mkRgb "base05");
    active-text = mkLiteral (mkRgb "base0D");
    urgent-text = mkLiteral (mkRgb "base08");
    alternate-normal-text = mkLiteral (mkAlternate normal-text (mkRgb "base05"));
    alternate-active-text = mkLiteral (mkAlternate active-text (mkRgb "base0D"));
    alternate-urgent-text = mkLiteral (mkAlternate urgent-text (mkRgb "base08"));
  };
in
{
  stylix.targets.rofi.enable = false;

  home.packages = [
    pkgs.papirus-icon-theme
    rofiVpnScript
  ];

  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun,window,ssh,vpn:${rofiVpnScript}/bin/rofi-vpn";
      show-icons = true;
      icon-theme = "Papirus-Dark";

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

  programs.niri.settings.binds."Mod+Space".action.spawn = [
    "rofi"
    "-show"
    "drun"
  ];
}
