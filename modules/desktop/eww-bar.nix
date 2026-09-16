{
  flake.modules.homeManager.eww-bar =
    { pkgs, themePalette, ... }:
    let
      bin = pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.gawk
        pkgs.jq
        pkgs.lm_sensors
        pkgs.procps
        pkgs.eww
        pkgs.niri
      ];

      bash = "${pkgs.bash}/bin/bash";

      colorPalette = {
        bg = "#${themePalette.background}";
        bgAlt = "#${themePalette.background-alt}";
        surface = "#${themePalette.background-selection}";
        border = "#${themePalette.popup.border-low-urgency}";
        fg = "#${themePalette.text}";
        fgMuted = "#${themePalette.popup.border-low-urgency}";
        accent = "#${themePalette.accent}";
        accent1 = "#${themePalette.accent}";
        accent2 = "#${themePalette.image.orange}";
        accent3 = "#${themePalette.image.green}";
        accent4 = "#${themePalette.image.cyan}";
        accent5 = "#${themePalette.image.cyan}";
        accent6 = "#${themePalette.image.purple}";
        accent7 = "#${themePalette.image.purple}";
        warning = "#${themePalette.image.yellow}";
        danger = "#${themePalette.image.red}";
        pillBg = "${colorPalette.accent}";
        onAccent = "${colorPalette.bg}";
      };

      cfg = {
        sensorChip = "k10temp-pci-00c3";
        sensorLabel = "Tctl";
        tempCrit = 85;
        tempClear = 78;
        cpuCrit = 90;
        cpuClear = 75;
        ramCrit = 90;
        ramClear = 82;
        diskCrit = 10;
        diskClear = 15;
        dwell = 3;
      };

      health = pkgs.replaceVarsWith {
        src = ../../resources/eww-health.sh;
        isExecutable = true;
        replacements = {
          inherit bin bash;
          inherit (cfg) sensorChip sensorLabel;
          dwell = toString cfg.dwell;
          tempCrit = toString cfg.tempCrit;
          tempClear = toString cfg.tempClear;
          cpuCrit = toString cfg.cpuCrit;
          cpuClear = toString cfg.cpuClear;
          ramCrit = toString cfg.ramCrit;
          ramClear = toString cfg.ramClear;
          diskCrit = toString cfg.diskCrit;
          diskClear = toString cfg.diskClear;
          inherit (colorPalette)
            accent1
            accent2
            accent3
            accent4
            fgMuted
            ;
        };
      };

      niriWorkspaces = pkgs.replaceVarsWith {
        src = ../../resources/eww-niri-workspaces.sh;
        isExecutable = true;
        replacements = { inherit bin bash; };
      };

      niriWindow = pkgs.replaceVarsWith {
        src = ../../resources/eww-niri-window.sh;
        isExecutable = true;
        replacements = { inherit bin bash; };
      };

      openWindows = pkgs.replaceVarsWith {
        src = ../../resources/eww-open-windows.sh;
        isExecutable = true;
        replacements = { inherit bin bash; };
      };

      yuck = pkgs.replaceVars ../../resources/eww-bar.yuck {
        health = "${health}";
        niriWorkspaces = "${niriWorkspaces}";
        niriWindow = "${niriWindow}";
        tempCrit = toString cfg.tempCrit;
        inherit (colorPalette)
          accent1
          accent2
          accent3
          accent4
          fgMuted
          ;
      };

      scss = ''
        $bg: ${colorPalette.bg};
        $fg: ${colorPalette.fg};
        $border: ${colorPalette.border};
        $danger: ${colorPalette.danger};
        $onAccent: ${colorPalette.onAccent};
        $accent: ${colorPalette.accent};
        $warning: ${colorPalette.warning};
        $surface: ${colorPalette.surface};
        $fgMuted: ${colorPalette.fgMuted};
        $pillBg: ${colorPalette.pillBg};

        ${builtins.readFile ../../resources/eww-bar.scss}
      '';
    in
    {
      xdg.configFile = {
        "eww/eww.yuck".source = yuck;
        "eww/eww.scss".text = scss;
      };

      systemd.user.services.eww-windows = {
        Unit = {
          Description = "Open eww windows, one bar per output";
          PartOf = [ "eww.service" ];
          After = [ "eww.service" ];
          Requires = [ "eww.service" ];
        };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${openWindows}";
        };
        Install.WantedBy = [ "eww.service" ];
      };

    };
}
