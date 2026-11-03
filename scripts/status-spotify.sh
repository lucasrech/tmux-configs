#!/usr/bin/env bash
# Outputs current Spotify track for tmux status bar via MPRIS/playerctl.
# Returns empty string when spotatui is not running or playerctl not installed.
# Install playerctl: sudo apt install playerctl

command -v playerctl &>/dev/null || exit 0

# Single call: status and track in one format string
OUT=$(playerctl -p spotatui metadata \
    --format '{{status}}|{{artist}} - {{title}}' 2>/dev/null) || exit 0

IFS='|' read -r STATUS META <<< "$OUT"

[ -z "$STATUS" ] || [ "$STATUS" = "Stopped" ] && exit 0
[ "$META" = " - " ] || [ -z "$META" ] && exit 0

# Truncate long track names
if [ "${#META}" -gt 40 ]; then
    META="${META:0:37}..."
fi

case "$STATUS" in
    Playing) printf ' #[fg=#585b70]|#[fg=#b4befe] ♪ %s' "$META" ;;
    Paused)  printf ' #[fg=#585b70]|#[fg=#cdd6f4] ⏸ %s' "$META" ;;
esac
