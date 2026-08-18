#!/usr/bin/env bash
# Builds a fully custom (non-GTK) month grid as JSON, week-by-week,
# Monday-first.
#
# Usage: calendar.sh [year] [month]
#   - With args: renders exactly that month (used by calendar-nav.sh, which
#     pushes the result straight in via `eww update CALENDAR=...`).
#   - Without args: falls back to the CAL_YEAR/CAL_MONTH eww vars, or
#     today if those are unset. Used by the periodic defpoll refresh.
#
# Requires: jq, GNU date (coreutils)

set -euo pipefail

if [ -n "${1:-}" ] && [ -n "${2:-}" ]; then
    CAL_YEAR="$1"
    CAL_MONTH="$2"
else
    CAL_YEAR=$(eww get CAL_YEAR 2>/dev/null || true)
    CAL_MONTH=$(eww get CAL_MONTH 2>/dev/null || true)
fi

TODAY_Y=$(date +%Y)
TODAY_M=$(date +%-m)
TODAY_D=$(date +%-d)

YEAR="${CAL_YEAR:-$TODAY_Y}"
MONTH="${CAL_MONTH:-$TODAY_M}"

MONTH_NAME=$(date -d "${YEAR}-${MONTH}-01" +%B)
DAYS_IN_MONTH=$(date -d "${YEAR}-${MONTH}-01 +1 month -1 day" +%-d)
FIRST_WD=$(date -d "${YEAR}-${MONTH}-01" +%u)   # 1=Mon .. 7=Sun
PREV_DAYS=$(date -d "${YEAR}-${MONTH}-01 -1 day" +%-d)

LEAD=$(( FIRST_WD - 1 ))
TOTAL=$(( LEAD + DAYS_IN_MONTH ))
ROWS=$(( (TOTAL + 6) / 7 ))
CELL_COUNT=$(( ROWS * 7 ))

IS_CURRENT_MONTH=false
if [ "$YEAR" = "$TODAY_Y" ] && [ "$MONTH" = "$TODAY_M" ]; then
    IS_CURRENT_MONTH=true
fi

jq -cn \
    --argjson lead "$LEAD" \
    --argjson daysInMonth "$DAYS_IN_MONTH" \
    --argjson prevDays "$PREV_DAYS" \
    --argjson cellCount "$CELL_COUNT" \
    --argjson isCurrentMonth "$IS_CURRENT_MONTH" \
    --argjson todayDay "$TODAY_D" \
    --arg year "$YEAR" --arg month "$MONTH" --arg monthName "$MONTH_NAME" \
    '
    def cellFor(i):
      if i < $lead then
        {day: ($prevDays - $lead + i + 1), muted: true, today: false, weekend: false}
      elif i < ($lead + $daysInMonth) then
        (i - $lead + 1) as $d
        | (($lead + $d - 1) % 7) as $wd
        | {day: $d, muted: false, today: ($isCurrentMonth and $d == $todayDay), weekend: ($wd == 5 or $wd == 6)}
      else
        {day: (i - $lead - $daysInMonth + 1), muted: true, today: false, weekend: false}
      end;
    ([range(0; $cellCount) | cellFor(.)]) as $all
    | {
        year: ($year | tonumber),
        month: ($month | tonumber),
        monthName: $monthName,
        weeks: [range(0; ($all | length); 7) | $all[.:(.+7)]]
      }
    '