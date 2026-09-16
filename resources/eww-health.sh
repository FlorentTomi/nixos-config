#!@bash@
PATH=@bin@
STATE="${XDG_RUNTIME_DIR:-/tmp}/eww-health.state"
streak=0; active=0; dismissed=0; active_key=""
[ -f "$STATE" ] && . "$STATE"

temp=$(sensors -u "@sensorChip@" 2>/dev/null \
  | awk -v l="@sensorLabel@" 'tolower($0) ~ tolower(l)":" { getline; print int($2) }' | head -1)
cpu=$(awk '/^cpu /{ u=$2+$4; t=$2+$4+$5; if (t) printf "%d", 100*u/t }' /proc/stat)
ram=$(free | awk '/^Mem:/ { printf "%d", 100*$3/$2 }')
disk=$(df -BG --output=avail / | awk 'NR==2 { gsub("G",""); print $1+0 }')
: "${temp:=0}" "${cpu:=0}" "${ram:=0}" "${disk:=999}"

# While a fault is active, stay latched onto it and judge recovery
# against its own `clear` threshold (disk inverted) instead of
# re-running the crit cascade, which would lose track of it the
# instant it dips back under crit.
if [ -n "$active_key" ]; then
  case "$active_key" in
    temp) val=$temp; max="@tempCrit@"; clear="@tempClear@"
          glyph="△"; label="TEMP"; unit="°"; hue="@accent2@"
          [ "$val" -le "$clear" ] && recovered=1 || recovered=0 ;;
    cpu)  val=$cpu; max="@cpuCrit@"; clear="@cpuClear@"
          glyph="󱐋"; label="CPU"; unit="%"; hue="@accent1@"
          [ "$val" -le "$clear" ] && recovered=1 || recovered=0 ;;
    ram)  val=$ram; max="@ramCrit@"; clear="@ramClear@"
          glyph="▣"; label="RAM"; unit="%"; hue="@accent3@"
          [ "$val" -le "$clear" ] && recovered=1 || recovered=0 ;;
    disk) val=$disk; max="@diskCrit@"; clear="@diskClear@"
          glyph="◴"; label="DISK"; unit="G"; hue="@accent4@"
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
  if   [ "$temp" -ge "@tempCrit@" ]; then
    key=temp; val=$temp; max="@tempCrit@"; clear="@tempClear@"
    glyph="△"; label="TEMP"; unit="°"; hue="@accent2@"; over=1
  elif [ "$cpu" -ge "@cpuCrit@" ]; then
    key=cpu; val=$cpu; max="@cpuCrit@"; clear="@cpuClear@"
    glyph="󱐋"; label="CPU"; unit="%"; hue="@accent1@"; over=1
  elif [ "$ram" -ge "@ramCrit@" ]; then
    key=ram; val=$ram; max="@ramCrit@"; clear="@ramClear@"
    glyph="▣"; label="RAM"; unit="%"; hue="@accent3@"; over=1
  elif [ "$disk" -le "@diskCrit@" ]; then
    key=disk; val=$disk; max="@diskCrit@"; clear="@diskClear@"
    glyph="◴"; label="DISK"; unit="G"; hue="@accent4@"; over=1
  else
    # Nothing in breach: the slot still plots CPU, because a flat line at the
    # bottom of the box is quieter than a glyph and keeps the slot's width.
    key=cpu; val=$cpu; max=100; clear=0
    glyph="󱐋"; label="CPU"; unit="%"; hue="@fgMuted@"; over=0
  fi

  # ---- hysteresis ----
  if [ "$over" = 1 ]; then
    streak=$((streak + 1))
    if [ "$streak" -ge "@dwell@" ]; then
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
