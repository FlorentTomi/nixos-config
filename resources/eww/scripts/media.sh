#!/usr/bin/env bash
# Emits one JSON line per line whenever playback state or track metadata
# changes. Meant to be used with (deflisten ...) in eww.
#
# Requires: playerctl, jq, curl (for remote cover art caching)

set -uo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/eww-media"
mkdir -p "$CACHE_DIR"

urldecode() {
    local data="${1//+/ }"
    printf '%b' "${data//%/\\x}"
}

resolve_art() {
    local art_raw="$1"
    local art_path=""

    if [[ "$art_raw" == file://* ]]; then
        art_path="$(urldecode "${art_raw#file://}")"
    elif [[ "$art_raw" == http* ]]; then
        local hash
        hash=$(printf '%s' "$art_raw" | md5sum | cut -d' ' -f1)
        art_path="$CACHE_DIR/$hash.jpg"
        [ -s "$art_path" ] || curl -fsSL -o "$art_path" "$art_raw" 2>/dev/null
        [ -s "$art_path" ] || art_path=""
    fi

    printf '%s' "$art_path"
}

emit() {
    local player status title artist album art_raw art_path

    player=$(playerctl -l 2>/dev/null | head -n1)

    if [ -z "$player" ]; then
        jq -nc '{status:"Stopped",title:"",artist:"",album:"",art:""}'
        return
    fi

    status=$(playerctl status 2>/dev/null || echo "Stopped")
    title=$(playerctl metadata title 2>/dev/null || echo "")
    artist=$(playerctl metadata artist 2>/dev/null || echo "")
    album=$(playerctl metadata album 2>/dev/null || echo "")
    art_raw=$(playerctl metadata mpris:artUrl 2>/dev/null || echo "")
    art_path=$(resolve_art "$art_raw")

    jq -nc \
        --arg status "$status" \
        --arg title "$title" \
        --arg artist "$artist" \
        --arg album "$album" \
        --arg art "$art_path" \
        '{status:$status,title:$title,artist:$artist,album:$album,art:$art}'
}

# Initial state
emit

# playerctl doesn't reliably fire "metadata" events on pure play/pause
# toggles, and doesn't fire "status" events on track changes. Following
# both, in parallel, covers both cases without flooding on position ticks.
( playerctl --follow status 2>/dev/null | while read -r _; do emit; done ) &
playerctl --follow metadata --format '{{status}}' 2>/dev/null | while read -r _; do emit; done
