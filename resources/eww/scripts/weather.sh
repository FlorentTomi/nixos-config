#!/usr/bin/env bash
# Fetches current weather from wttr.in and prints it as JSON.
# Set EWW_WEATHER_LOCATION (e.g. "Marseille") to pin a city, otherwise
# wttr.in falls back to IP-based geolocation.
#
# Requires: curl, jq

set -uo pipefail

LOCATION="${EWW_WEATHER_LOCATION:-}"

resp=$(curl -fsSL -m 10 "https://wttr.in/${LOCATION}?format=j1" 2>/dev/null)

if [ -z "$resp" ]; then
    jq -nc '{ok:false,temp:"--",feels:"--",desc:"Unavailable",humidity:"--",wind:"--",icon:"⚠️"}'
    exit 0
fi

code=$(jq -r '.current_condition[0].weatherCode // "113"' <<<"$resp")

case "$code" in
    113) icon="☀️" ;;                                          # Sunny / Clear
    116) icon="🌤️" ;;                                          # Partly cloudy
    119|122) icon="☁️" ;;                                       # Cloudy / Overcast
    143|248|260) icon="🌫️" ;;                                   # Fog / Mist
    176|179|182|185|263|266|293|296|299|302|305|308|311|314|317|320|350|353|356|359) icon="🌧️" ;;  # Rain / Drizzle / Sleet
    227|230|323|326|329|332|335|338|341|344|362|365|368|371|374|377) icon="❄️" ;;                    # Snow
    200|386|389|392|395) icon="⛈️" ;;                           # Thunderstorm
    *) icon="🌡️" ;;
esac

jq -c \
    --arg icon "$icon" \
    '.current_condition[0] as $c
     | .nearest_area[0] as $a
     | {
         ok: true,
         temp: $c.temp_C,
         feels: $c.FeelsLikeC,
         desc: $c.weatherDesc[0].value,
         humidity: $c.humidity,
         wind: $c.windspeedKmph,
         location: (($a.areaName[0].value // "") ),
         icon: $icon
       }' <<<"$resp"
