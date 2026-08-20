#!/usr/bin/env bash
# Single combined poll for CPU / memory / disk / GPU stats, so eww only
# spawns one process per tick instead of four.
#
# Requires: jq, coreutils (/proc, free, df), nvtop or nvidia-smi (for GPU)

set -uo pipefail

# --- CPU: sample /proc/stat twice, 200ms apart ---
read -r _ u1 n1 s1 i1 w1 irq1 sirq1 _ < <(awk '/^cpu /{print}' /proc/stat)
sleep 0.2
read -r _ u2 n2 s2 i2 w2 irq2 sirq2 _ < <(awk '/^cpu /{print}' /proc/stat)

idle1=$((i1 + w1)); idle2=$((i2 + w2))
total1=$((u1 + n1 + s1 + i1 + w1 + irq1 + sirq1))
total2=$((u2 + n2 + s2 + i2 + w2 + irq2 + sirq2))
totald=$((total2 - total1)); idled=$((idle2 - idle1))

cpu_pct=0
[ "$totald" -gt 0 ] && cpu_pct=$(( (100 * (totald - idled)) / totald ))

# --- Memory ---
read -r mem_total mem_used <<<"$(free -m | awk '/^Mem:/{print $2, $3}')"
mem_pct=0
[ "${mem_total:-0}" -gt 0 ] && mem_pct=$(( 100 * mem_used / mem_total ))

# --- Disk (root filesystem) ---
read -r disk_used disk_total disk_pct <<<"$(df -BG / 2>/dev/null | awk 'NR==2{gsub("G","",$3); gsub("G","",$2); gsub("%","",$5); print $3, $2, $5}')"

# --- GPU ---
# Prefer nvtop (already used by this host's waybar config, so it's known
# to work); fall back to nvidia-smi if nvtop isn't around.
gpu_util=0; gpu_mem_used=0; gpu_mem_total=0; gpu_temp=0

if command -v nvtop >/dev/null 2>&1; then
    gpu_json=$(nvtop -s 2>/dev/null | jq -c '.[0] // empty' 2>/dev/null)
    if [ -n "$gpu_json" ]; then
        gpu_util=$(jq -r '(.gpu_util // "0%") | rtrimstr("%")' <<<"$gpu_json")
        gpu_temp=$(jq -r '(.temp // "0C") | rtrimstr("C")' <<<"$gpu_json")
        gpu_mem_used_b=$(jq -r '.mem_used // "0"' <<<"$gpu_json")
        gpu_mem_total_b=$(jq -r '.mem_total // "0"' <<<"$gpu_json")
        gpu_mem_used=$(( gpu_mem_used_b / 1024 / 1024 ))
        gpu_mem_total=$(( gpu_mem_total_b / 1024 / 1024 ))
    fi
elif command -v nvidia-smi >/dev/null 2>&1; then
    IFS=',' read -r gpu_util gpu_mem_used gpu_mem_total gpu_temp < <(
        nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu \
            --format=csv,noheader,nounits 2>/dev/null | tr -d ' '
    )
    gpu_util="${gpu_util:-0}"; gpu_mem_used="${gpu_mem_used:-0}"
    gpu_mem_total="${gpu_mem_total:-0}"; gpu_temp="${gpu_temp:-0}"
fi

gpu_util="${gpu_util:-0}"; gpu_mem_used="${gpu_mem_used:-0}"
gpu_mem_total="${gpu_mem_total:-0}"; gpu_temp="${gpu_temp:-0}"

# Guard against non-numeric readings (e.g. "N/A" when a GPU is asleep or
# a field is missing) so jq --argjson never gets handed invalid JSON.
is_num() { [[ "$1" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; }
is_num "$gpu_util" || gpu_util=0
is_num "$gpu_mem_used" || gpu_mem_used=0
is_num "$gpu_mem_total" || gpu_mem_total=0
is_num "$gpu_temp" || gpu_temp=0

# Pre-format GB figures here (one decimal place) so the yuck side never
# needs to do arithmetic on the values - just string interpolation.
mem_used_gb=$(awk -v v="${mem_used:-0}" 'BEGIN{printf "%.1f", v/1024}')
mem_total_gb=$(awk -v v="${mem_total:-0}" 'BEGIN{printf "%.1f", v/1024}')

jq -nc \
    --argjson cpu "${cpu_pct:-0}" \
    --argjson mem_used "${mem_used:-0}" --argjson mem_total "${mem_total:-0}" --argjson mem_pct "${mem_pct:-0}" \
    --arg mem_used_gb "$mem_used_gb" --arg mem_total_gb "$mem_total_gb" \
    --argjson disk_used "${disk_used:-0}" --argjson disk_total "${disk_total:-0}" --argjson disk_pct "${disk_pct:-0}" \
    --argjson gpu_util "$gpu_util" --argjson gpu_mem_used "$gpu_mem_used" \
    --argjson gpu_mem_total "$gpu_mem_total" --argjson gpu_temp "$gpu_temp" \
    '{
        cpu: {pct: $cpu},
        mem: {used: $mem_used, total: $mem_total, pct: $mem_pct, used_gb: $mem_used_gb, total_gb: $mem_total_gb},
        disk: {used: $disk_used, total: $disk_total, pct: $disk_pct},
        gpu: {util: $gpu_util, mem_used: $gpu_mem_used, mem_total: $gpu_mem_total, temp: $gpu_temp}
    }'
