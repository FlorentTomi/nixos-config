#!/usr/bin/env bash
# Moves the calendar widget's displayed month and pushes a freshly
# rendered grid straight into eww via `eww update CALENDAR=...` (not
# `eww poll`, which doesn't reliably force a re-run in all eww versions).
#
# Usage: calendar-nav.sh {next|prev|today}

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DIR="${1:?usage: calendar-nav.sh next|prev|today}"

CAL_YEAR=$(eww get CAL_YEAR 2>/dev/null || true)
CAL_MONTH=$(eww get CAL_MONTH 2>/dev/null || true)
YEAR="${CAL_YEAR:-$(date +%Y)}"
MONTH="${CAL_MONTH:-$(date +%-m)}"

case "$DIR" in
    today)
        NY=$(date +%Y)
        NM=$(date +%-m)
        eww update CAL_YEAR="" CAL_MONTH=""
        ;;
    next|prev)
        sign="+1"
        [ "$DIR" = "prev" ] && sign="-1"
        NEW=$(date -d "${YEAR}-${MONTH}-01 ${sign} month" +%Y-%m)
        NY="${NEW%-*}"
        NM="${NEW#*-}"
        NM="${NM#0}"
        eww update CAL_YEAR="$NY" CAL_MONTH="$NM"
        ;;
    *)
        echo "unknown direction: $DIR" >&2
        exit 1
        ;;
esac

NEW_JSON=$("$SCRIPT_DIR/calendar.sh" "$NY" "$NM")
[ -n "$NEW_JSON" ] && eww update "CALENDAR=$NEW_JSON"