#!@bash@
PATH=@bin@
eww ping >/dev/null 2>&1 || exit 1
niri msg -j outputs | jq -r 'to_entries[] | .value.name // .key' \
  | while read -r out; do
      [ -n "$out" ] || continue
      eww open bar --id "bar-$out" --screen "$out" --arg output="$out" 2>/dev/null || true
    done
# The popups are single-instance on the focused monitor.
eww open anomaly 2>/dev/null || true
eww open calendar 2>/dev/null || true
