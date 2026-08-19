#!/usr/bin/env bash
set -euo pipefail

next_event=$(khal list -a Alexandre --format "{start-date} {start-time} {title}" --day-format "" now 30d 2>/dev/null | head -n 1) || true

if [[ -z "$next_event" ]]; then 
  echo "No event"
else
  echo "$next_event"
fi