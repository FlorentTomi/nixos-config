{
  flake.modules.homeManager.eww =
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
      ];

      colorPalette = {
        bg = "#${themePalette.background}";
        bgAlt = "#${themePalette.background-alt}";
        surface = "#${themePalette.background-selection}";
        border = "#${themePalette.popup.border-low-urgency}";
        fg = "#${themePalette.text}";
        # base16's base03 slot ("comments / muted foreground") — GTK's CSS
        # engine has no color-mix()/runtime blending, so use the palette's
        # own muted color instead of computing one.
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
        # Ink ON a filled accent — so it must contrast with the fill, not match
        # it. accent-on-danger fails; bg-on-danger is the readable pair.
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
        diskClear = 15; # GB free — inverted, lower is worse
        dwell = 3; # consecutive breaches before the popup
      };

      health = pkgs.writeShellScript "eww-health" ''
        PATH=${bin}
        STATE="''${XDG_RUNTIME_DIR:-/tmp}/eww-health.state"
        streak=0; active=0; dismissed=0; active_key=""
        [ -f "$STATE" ] && . "$STATE"

        temp=$(sensors -u "${cfg.sensorChip}" 2>/dev/null \
          | awk -v l="${cfg.sensorLabel}" 'tolower($0) ~ tolower(l)":" { getline; print int($2) }' | head -1)
        cpu=$(awk '/^cpu /{ u=$2+$4; t=$2+$4+$5; if (t) printf "%d", 100*u/t }' /proc/stat)
        ram=$(free | awk '/^Mem:/ { printf "%d", 100*$3/$2 }')
        disk=$(df -BG --output=avail / | awk 'NR==2 { gsub("G",""); print $1+0 }')
        : "''${temp:=0}" "''${cpu:=0}" "''${ram:=0}" "''${disk:=999}"

        # While a fault is active, stay latched onto it and judge recovery
        # against its own `clear` threshold (disk inverted) instead of
        # re-running the crit cascade, which would lose track of it the
        # instant it dips back under crit.
        if [ -n "$active_key" ]; then
          case "$active_key" in
            temp) val=$temp; max=${toString cfg.tempCrit}; clear=${toString cfg.tempClear}
                  glyph="△"; label="TEMP"; unit="°"; hue="${colorPalette.accent2}"
                  [ "$val" -le "$clear" ] && recovered=1 || recovered=0 ;;
            cpu)  val=$cpu; max=${toString cfg.cpuCrit}; clear=${toString cfg.cpuClear}
                  glyph="▚"; label="CPU"; unit="%"; hue="${colorPalette.accent1}"
                  [ "$val" -le "$clear" ] && recovered=1 || recovered=0 ;;
            ram)  val=$ram; max=${toString cfg.ramCrit}; clear=${toString cfg.ramClear}
                  glyph="▣"; label="RAM"; unit="%"; hue="${colorPalette.accent3}"
                  [ "$val" -le "$clear" ] && recovered=1 || recovered=0 ;;
            disk) val=$disk; max=${toString cfg.diskCrit}; clear=${toString cfg.diskClear}
                  glyph="◴"; label="DISK"; unit="G"; hue="${colorPalette.accent4}"
                  [ "$val" -ge "$clear" ] && recovered=1 || recovered=0 ;;
          esac
          key=$active_key
          if [ "$recovered" = 1 ]; then
            active=0; dismissed=0; active_key=""; streak=0
          fi
        fi

        # First threshold crossed wins — one slot, so one fault at a time.
        # `max` is the crit value itself, so the trace presses the ceiling in breach
        # and the graph reads as "at the limit" with no labelled axis.
        if [ -z "$active_key" ]; then
          if   [ "$temp" -ge ${toString cfg.tempCrit} ]; then
            key=temp; val=$temp; max=${toString cfg.tempCrit}; clear=${toString cfg.tempClear}
            glyph="△"; label="TEMP"; unit="°"; hue="${colorPalette.accent2}"; over=1
          elif [ "$cpu" -ge ${toString cfg.cpuCrit} ]; then
            key=cpu; val=$cpu; max=${toString cfg.cpuCrit}; clear=${toString cfg.cpuClear}
            glyph="▚"; label="CPU"; unit="%"; hue="${colorPalette.accent1}"; over=1
          elif [ "$ram" -ge ${toString cfg.ramCrit} ]; then
            key=ram; val=$ram; max=${toString cfg.ramCrit}; clear=${toString cfg.ramClear}
            glyph="▣"; label="RAM"; unit="%"; hue="${colorPalette.accent3}"; over=1
          elif [ "$disk" -le ${toString cfg.diskCrit} ]; then
            key=disk; val=$disk; max=${toString cfg.diskCrit}; clear=${toString cfg.diskClear}
            glyph="◴"; label="DISK"; unit="G"; hue="${colorPalette.accent4}"; over=1
          else
            # Nothing in breach: the slot still plots CPU, because a flat line at the
            # bottom of the box is quieter than a glyph and keeps the slot's width.
            key=cpu; val=$cpu; max=100; clear=0
            glyph="▚"; label="CPU"; unit="%"; hue="${colorPalette.fgMuted}"; over=0
          fi

          # ---- hysteresis ----
          if [ "$over" = 1 ]; then
            streak=$((streak + 1))
            if [ "$streak" -ge ${toString cfg.dwell} ]; then
              active=1; active_key=$key
            fi
          else
            streak=0
          fi
        fi

        printf 'streak=%s\nactive=%s\ndismissed=%s\nactive_key=%s\n' "$streak" "$active" "$dismissed" "$active_key" > "$STATE"

        open=false
        [ "$active" = 1 ] && [ "$dismissed" = 0 ] && open=true
        [ "$active" = 1 ] && cls=crit || cls=ok

        jq -nc \
          --argjson temp "$temp" --argjson cpu "$cpu" --argjson ram "$ram" --argjson disk "$disk" \
          --argjson val "$val" --argjson max "$max" --argjson open "$open" \
          --arg key "$key" --arg glyph "$glyph" --arg label "$label" --arg unit "$unit" \
          --arg hue "$hue" --arg cls "$cls" \
          '{temp:$temp,cpu:$cpu,ram:$ram,disk:$disk,val:$val,max:$max,
            key:$key,glyph:$glyph,label:$label,unit:$unit,hue:$hue,class:$cls,open:$open}'
      '';

      dismiss = pkgs.writeShellScript "eww-health-dismiss" ''
        PATH=${bin}
        STATE="''${XDG_RUNTIME_DIR:-/tmp}/eww-health.state"
        streak=0; active=0; dismissed=0; active_key=""
        [ -f "$STATE" ] && . "$STATE"
        printf 'streak=%s\nactive=%s\ndismissed=1\nactive_key=%s\n' "$streak" "$active" "$active_key" > "$STATE"
      '';

      # Emits every workspace WITH its output, because eww vars are global: one
      # daemon feeds every bar, so the per-monitor filter has to happen in yuck
      # against the window's own `output` argument.
      niriWorkspaces = pkgs.writeShellScript "eww-niri-workspaces" ''
        PATH=${bin}:${pkgs.niri}/bin
        emit() {
          niri msg -j workspaces \
            | jq -c '[.[] | {id, idx, output: (.output // "unknown"),
                             active: .is_active, urgent: (.is_urgent // false)}]
                     | sort_by(.output, .idx)'
        }
        emit
        niri msg -j event-stream \
          | jq --unbuffered -nc 'inputs | select(has("WorkspacesChanged") or has("WorkspaceActivated") or has("WorkspaceUrgencyChanged"))' \
          | while read -r _; do emit; done
      '';

      # niri has exactly one focused window across the whole session, so a
      # per-monitor title cannot come from `focused-window`. Instead: for each
      # output, take its ACTIVE workspace and report the window on it — the
      # focused one if focus happens to be there, otherwise the first window on
      # that workspace. So the bar on an unfocused monitor names that monitor's
      # own window rather than mirroring the focused one or going blank.
      #
      # Caveat: niri's `windows` list is not MRU-ordered, so the fallback pick on
      # an unfocused output is arbitrary when its workspace holds several windows.
      niriWindow = pkgs.writeShellScript "eww-niri-window" ''
        PATH=${bin}:${pkgs.niri}/bin
        emit() {
          ws=$(niri msg -j workspaces)
          wins=$(niri msg -j windows)
          jq -nc --argjson ws "$ws" --argjson wins "$wins" '
            reduce ( $ws[] | select(.is_active) ) as $w ({};
              . + { ($w.output // "unknown"):
                    ( [ $wins[] | select(.workspace_id == $w.id) ] as $c
                      | ( first($c[] | select(.is_focused)) // $c[0] // null )
                      | if . == null
                        then { title: "", app: "", floating: false }
                        else { title: (.title // ""), app: (.app_id // ""),
                               floating: (.is_floating // false) }
                        end ) })'
        }
        emit
        # Workspace switches change which window an output is showing, so this
        # listens to workspace events too, not just window ones.
        niri msg -j event-stream \
          | jq --unbuffered -nc 'inputs
              | if has("WindowFocusChanged") or has("WindowsChanged") or has("WindowOpenedOrChanged")
                   or has("WindowClosed") or has("WorkspaceActivated") or has("WorkspacesChanged")
                then "refresh" else empty end' \
          | while read -r _; do emit; done
      '';

      # One bar per output. eww vars are daemon-global, so each instance is
      # opened with --arg output=<name> and filters the shared vars itself.
      openWindows = pkgs.writeShellScript "eww-open-windows" ''
        PATH=${bin}:${pkgs.niri}/bin
        eww ping >/dev/null 2>&1 || exit 1
        niri msg -j outputs | jq -r 'to_entries[] | .value.name // .key' \
          | while read -r out; do
              [ -n "$out" ] || continue
              eww open bar --id "bar-$out" --screen "$out" --arg output="$out" 2>/dev/null || true
            done
        # The popups are single-instance on the focused monitor.
        eww open anomaly 2>/dev/null || true
        eww open calendar 2>/dev/null || true
      '';

      yuck = ''
        ;; ---- data ----------------------------------------------------------------
        (defpoll health :interval "2s" :initial `{"class":"ok","glyph":"▚","label":"CPU","unit":"%","val":0,"max":100,"temp":0,"cpu":0,"ram":0,"disk":0,"hue":"${colorPalette.fgMuted}","open":false}` "${health}")
        (deflisten workspaces :initial "[]" "${niriWorkspaces}")
        (deflisten win :initial "{}" "${niriWindow}")
        (defpoll clock_time :interval "10s" "date '+%H:%M'")
        (defpoll clock_date :interval "1h" "date '+%a %d %b'")
        (defvar cal_open false)
        (defvar title_hover false)

        ;; ---- bar -----------------------------------------------------------------
        ;; Window spans the full monitor width (eww's geometry parser has no
        ;; calc(), and this build's :anchor takes only one horizontal token, so
        ;; there's no width-independent stretch-anchor trick either). The 8px
        ;; left/right inset is done here instead, as a margin on the content.
        ;;
        ;; `output` threads down from the window argument: both niri vars are
        ;; session-wide, so every island that shows per-monitor state filters on it.
        (defwidget bar [output]
          (centerbox :class "bar" :orientation "h" :style "margin: 0 8px;"
            (box :halign "start" (island-left :output output))
            (box :halign "center" (island-title :output output))
            (box :halign "end" (island-right))))

        (defwidget island-left [output]
          (box :class "island" :space-evenly false :spacing 0
            (button :class "power" :onclick "wleave" "⏻")
            (box :class "sep")
            (box :class "dots" :space-evenly false :spacing 0
              (for ws in {jq(workspaces, '[.[] | select(.output == "' + output + '")]')}
                (button :class {ws.active ? "dot active" : ws.urgent ? "dot urgent" : "dot"}
                        :onclick "niri msg action focus-workspace ''${ws.idx}" "●")))))

        ;; The revealer wraps the ISLAND, not the label — otherwise an empty
        ;; workspace leaves the island's fill and border behind as an empty nub.
        ;; centerbox positions this structurally, so it can size to its content:
        ;; no 48-character reservation, and no drift when the left island grows.
        ;; jq() hands back the JSON *value*, so a string arrives encoded — with
        ;; its quotes, and an empty title as the two-char string `""`, which is
        ;; not equal to "". The third argument switches it to raw output, which
        ;; both unquotes the label and makes the reveal test work.
        (defwidget island-title [output]
          (revealer :transition "crossfade" :duration "150ms"
                    :reveal {jq(win, '.["' + output + '"].title // ""', "r") != ""}
            (eventbox :onhover "''${EWW_CMD} update title_hover=true"
                      :onhoverlost "''${EWW_CMD} update title_hover=false"
              (box :class "island" :space-evenly false
                (label :class "title"
                       :text {jq(win, '.["' + output + '"].title // ""', "r")}
                       :limit-width {title_hover ? 120 : 48}
                       :truncate true)))))

        (defwidget island-right []
          (box :class "island" :space-evenly false :spacing 0
            (anomaly)
            (box :class "sep")
            (systray :class "tray" :icon-size 14 :spacing 8 :prepend-new false)
            (box :class "sep")
            (clock)
            (bell)))

        ;; ---- the anomaly slot ----------------------------------------------------
        ;; overlay takes the size of its first child, so the ring costs no width.
        ;; The graph is always mounted, so it always has history to show.
        (defwidget anomaly []
          (tooltip
            (stats-card)
            (eventbox :class "anomaly-hit" :onclick "foot --app-id=floating-stats -- btop"
              (overlay
                (graph :class {"spark ''${health.class}"}
                       :value {health.val}
                       :time-range "3min"
                       :min 0 :max {health.max}
                       :dynamic false
                       :thickness 2
                       :line-style "round"
                       :width 46 :height 20)
                (box :halign "center" :valign "center"
                  (label :class {"glyph ''${health.class}"} :text {health.glyph}))))))

        ;; tooltip's first child is a WIDGET, not a markup string — this is the
        ;; glance that used to need a floated btop.
        (defwidget stats-card []
          (box :class "card" :orientation "v" :space-evenly false :spacing 6
            (stat-row :label "CPU"  :value {health.cpu}  :unit "%" :max 100 :hue "${colorPalette.accent1}")
            (stat-row :label "TEMP" :value {health.temp} :unit "°" :max ${toString cfg.tempCrit} :hue "${colorPalette.accent2}")
            (stat-row :label "RAM"  :value {health.ram}  :unit "%" :max 100 :hue "${colorPalette.accent3}")
            (stat-row :label "DISK" :value {health.disk} :unit "G" :max 100 :hue "${colorPalette.accent4}")))

        (defwidget stat-row [label value unit max hue]
          (box :class "stat-row" :space-evenly false :spacing 8
            (label :class "stat-key" :text label :width 44 :xalign 0)
            (graph :class "stat-spark" :style "color: ''${hue};"
                   :value value :time-range "3min" :min 0 :max max
                   :dynamic false :thickness 2 :width 96 :height 18)
            (label :class "stat-val" :text "''${value}''${unit}" :width 44 :xalign 1)))

        (defwidget clock []
          (eventbox :class "clock-hit" :onclick "''${EWW_CMD} update cal_open=''${!cal_open}"
            (box :space-evenly false :spacing 8
              (label :class "clock-date" :text clock_date)
              (label :class "clock-time" :text clock_time))))

        ;; Dormant at 25%, never absent: appearing from nothing reintroduces exactly
        ;; the jitter the layout was built to avoid. The COUNT slides out instead.
        (defwidget bell []
          (eventbox :class "bell-hit" :onclick "swaync-client -t -sw"
            (box :space-evenly false :spacing 0
              (label :class "bell" :text "◔")
              (revealer :transition "slideright" :duration "200ms" :reveal false
                (label :class "bell-count" :text "")))))

        ;; ---- the anomaly popup ---------------------------------------------------
        ;; Always-open window, revealer inside. Deliberate: a collapsed revealer keeps
        ;; its child MOUNTED, so the graph below accumulates the whole climb while
        ;; hidden and is already populated the moment it slides down. `eww open` on
        ;; breach would hand you an empty graph, which is the opposite of the point.
        (defwidget anomaly-popup []
          (revealer :transition "slidedown" :duration "220ms" :reveal {health.open}
            (eventbox :onclick "${dismiss}"
              (box :class {"popup ''${health.key}"} :orientation "v" :space-evenly false :spacing 6
                (box :class "popup-head" :space-evenly false
                  (label :class "popup-key" :text "▲ ''${health.label}")
                  (box)
                  (label :class "popup-val" :text "''${health.val}''${health.unit}"))
                (graph :class "popup-graph" :style "color: ''${health.hue};"
                       :value {health.val} :time-range "5min"
                       :min 0 :max {health.max} :dynamic false
                       :thickness 2 :line-style "round" :height 44)
                (box :class "popup-foot" :space-evenly false
                  (label :class "popup-note" :text "ceiling ''${health.max}''${health.unit}")
                  (box)
                  (label :class "popup-note" :text "click to dismiss"))))))

        (defwidget calendar-popup []
          (revealer :transition "slidedown" :duration "180ms" :reveal cal_open
            (box :class "card"
              (calendar :class "cal" :show-week-numbers false :show-details false
                        :onclick "khal list {2}-{1}-{0} 1d"))))

        ;; ---- windows -------------------------------------------------------------
        ;; Opened once per output by eww-open-windows, which passes the name in.
        (defwindow bar [output]
          :monitor output
          :geometry (geometry :x "0px" :y "8px" :width "100%" :height "26px" :anchor "top center")
          :stacking "fg" :exclusive true :focusable false
          (bar :output output))

        ;; exclusive false: it must not reserve space, or the desktop reflows on alert.
        (defwindow anomaly
          :monitor 0
          :geometry (geometry :x "8px" :y "40px" :width "240px" :anchor "top right")
          :stacking "fg" :exclusive false :focusable false
          (anomaly-popup))

        (defwindow calendar
          :monitor 0
          :geometry (geometry :x "8px" :y "40px" :width "260px" :anchor "top right")
          :stacking "fg" :exclusive false :focusable false
          (calendar-popup))
      '';

      scss = with colorPalette; ''
        * {
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 11px;
          font-weight: bold;
          border: none;
          border-radius: 0;
          box-shadow: none;
          min-height: 0;
          text-shadow: none;
        }

        window { background-color: transparent; color: ${fg}; }

        /* ---- the three islands ---------------------------------------------- */
        .island {
          background-color: ${bg};
          border: 1px solid ${border};
          padding: 0 4px;
        }

        /* Inset rule: 4px top/bottom on a 26px bar is the ~60% height, and is the
           ceiling that does not grow the bar. */
        .sep {
          background-color: ${border};
          min-width: 1px;
          margin: 4px 4px;
        }

        button, .clock-hit, .bell-hit, .anomaly-hit {
          background-color: transparent;
          color: ${fg};
          padding: 0 8px;
        }

        /* ---- left island ---------------------------------------------------- */
        .power { color: ${danger}; }
        .power:hover { background-color: ${danger}; color: ${onAccent}; }

        .dot {
          padding: 0 5px;
          color: ${border};
          font-size: 9px;
        }
        .dot.active { color: ${accent}; }
        .dot.urgent { color: ${warning}; }
        .dot:hover { background-color: ${surface}; }

        /* ---- centre island -------------------------------------------------- */
        .title { color: ${fg}; font-weight: normal; padding: 0 12px; }

        /* ---- anomaly slot --------------------------------------------------- */
        /* Silent when healthy: a flat trace at the floor of the box, and the glyph
           muted on top of it. */
        .spark.ok    { color: ${fgMuted}; }
        .spark.crit  { color: ${danger}; }
        .glyph.ok    { color: ${fgMuted}; font-weight: normal; }
        .glyph.crit  { color: ${danger}; }
        .anomaly-hit:hover { background-color: ${surface}; }

        /* ---- clock + bell --------------------------------------------------- */
        .clock-date { color: ${fgMuted}; font-weight: normal; padding-right: 8px; }
        .clock-time { color: ${accent}; }

        .bell { color: ${fgMuted}; opacity: 0.25; padding: 0 4px; }
        .bell.has-notifications { color: ${warning}; opacity: 1; }
        .bell-count { color: ${warning}; padding-right: 4px; }

        /* ---- popovers: same contract as the islands ------------------------- */
        .card, .popup {
          background-color: ${bg};
          border: 1px solid ${border};
          padding: 8px 10px;
        }

        .stat-key { color: ${fgMuted}; font-weight: normal; }
        .stat-val { color: ${fg}; }

        .popup-key  { color: ${danger}; }
        .popup-val  { color: ${danger}; font-weight: bold; }
        .popup-note { color: ${fgMuted}; font-size: 9px; font-weight: normal; }

        .cal { background-color: ${bg}; color: ${fg}; }
        .cal:selected { background-color: ${pillBg}; color: ${onAccent}; }

        tooltip { background-color: ${bg}; border: 1px solid ${border}; }
        tooltip label { color: ${fg}; font-weight: normal; }
      '';
    in
    {
      xdg.configFile = {
        "eww/eww.yuck".text = yuck;
        "eww/eww.scss".text = scss;
      };

      programs.eww = {
        enable = true;
        systemd.enable = true;
      };

      # programs.eww's unit starts the daemon but opens nothing. Kept separate
      # rather than overriding that unit, so the module owns the daemon and this
      # owns the window set — and it re-runs on output changes if you wire it to.
      systemd.user.services.eww-windows = {
        Unit = {
          Description = "Open eww windows, one bar per output";
          PartOf = [ "graphical-session.target" ];
          After = [ "eww.service" ];
          Requires = [ "eww.service" ];
        };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${openWindows}";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
