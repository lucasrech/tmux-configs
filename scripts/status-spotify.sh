#!/usr/bin/env bash
# Spotify status segment for tmux status bar line 2.
# Always visible — playing / paused / idle / offline.
# Source: MPRIS via playerctl. No Spotify API calls. No pane dependency.
# Marquee scrolling for long track names (deterministic, epoch-based offset).
#
# Usage (from tmux format string):
#   #(~/.config/tmux/scripts/status-spotify.sh #{client_width})

TERM_WIDTH="${1:-120}"
CACHE_DIR="${XDG_RUNTIME_DIR:-/tmp/user-${UID:-$(id -u)}}"
CACHE_FILE="$CACHE_DIR/tmux-spotify-cache"
CACHE_TTL=5        # seconds between playerctl queries
# Conservative estimate of chars used by NET/VPN/RAM/LOAD separators + date/time.
# Reduce if your NET/VPN names are very short; raise if they are very long.
FIXED_CHARS=82
# Width tiers for the Spotify segment:
#   NARROW  (<  15 chars): show icon + "Spotify" only
#   SHORT   (15-29 chars): show truncated text, no marquee
#   WIDE    (>= 30 chars): show full text with marquee when needed

avail=$(( TERM_WIDTH - FIXED_CHARS ))
[ "$avail" -lt 1 ] && avail=1  # floor at 1 (evaluated below via tier)

# ── CACHE ────────────────────────────────────────────────────────────────────
# playerctl is only called every CACHE_TTL seconds.
# All other invocations (marquee animation frames) read the cached file.

now=$(date +%s)
mkdir -p "$CACHE_DIR"

_needs_refresh() {
    local ts
    [ -f "$CACHE_FILE" ] || return 0
    ts=$(cut -f1 "$CACHE_FILE" 2>/dev/null) || return 0
    [ -z "$ts" ] && return 0
    [ $(( now - ts )) -ge $CACHE_TTL ]
}

_refresh_cache() {
    local status="OFFLINE" artist="" title="" player=""

    if command -v playerctl &>/dev/null; then
        # Preferred player priority: spotatui → Spotify Desktop → others
        while IFS= read -r p; do
            case "$p" in
                spotatui)        player="spotatui"; break ;;
                Spotify|spotify) [ -z "$player" ] && player="$p" ;;
            esac
        done < <(playerctl -l 2>/dev/null)

        if [ -n "$player" ]; then
            local out
            out=$(playerctl -p "$player" metadata \
                --format '{{status}}|{{artist}}|{{title}}' 2>/dev/null)
            if [ -n "$out" ]; then
                IFS='|' read -r status artist title <<< "$out"
            else
                status="Stopped"
            fi
        fi
    fi

    # Atomic write via temp file to avoid partial reads
    printf '%d\t%s\t%s\t%s\n' "$now" "$status" "$artist" "$title" \
        > "${CACHE_FILE}.tmp" \
        && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
}

_needs_refresh && _refresh_cache

IFS=$'\t' read -r _ status artist title < "$CACHE_FILE" 2>/dev/null
status="${status:-OFFLINE}"
artist="${artist:-}"
title="${title:-}"

# ── MARQUEE ──────────────────────────────────────────────────────────────────
# offset = epoch % loop_length  →  advances 1 char/second with status-interval 1.
# `wc -m` counts Unicode characters (not bytes).
# `cut -c` selects by character position in a UTF-8 locale.

_marquee() {
    local text="$1" width="$2"

    local char_len
    char_len=$(printf '%s' "$text" | wc -m 2>/dev/null | xargs) \
        || char_len=${#text}

    if [ "$char_len" -le "$width" ]; then
        printf '%s' "$text"
        return
    fi

    local sep="   •   "
    local loop="${text}${sep}"
    local loop_len
    loop_len=$(printf '%s' "$loop" | wc -m 2>/dev/null | xargs) \
        || loop_len=${#loop}

    local offset=$(( now % loop_len ))
    printf '%s%s' "$loop" "$loop" | cut -c$(( offset + 1 ))-$(( offset + width ))
}

# ── BUILD TEXT ───────────────────────────────────────────────────────────────

_track_text() {
    local a="$1" t="$2"
    if   [ -n "$a" ] && [ -n "$t" ]; then printf '%s — %s' "$a" "$t"
    elif [ -n "$t" ];                 then printf '%s' "$t"
    elif [ -n "$a" ];                 then printf '%s' "$a"
    else                                   printf 'Unknown Track'
    fi
}

# ── OUTPUT ───────────────────────────────────────────────────────────────────

# Narrow terminal: show only icon + label
if [ "$avail" -lt 15 ]; then
    case "$status" in
        Playing) printf '#[fg=#a6e3a1]▶#[fg=#cdd6f4] Spotify' ;;
        Paused)  printf '#[fg=#f9e2af]⏸#[fg=#cdd6f4] Spotify' ;;
        *)       printf '#[fg=#585b70]● Spotify' ;;
    esac
    exit 0
fi

case "$status" in
    Playing)
        text=$(_track_text "$artist" "$title")
        if [ "$avail" -ge 30 ]; then
            out=$(_marquee "$text" "$avail")
        else
            out=$(printf '%s' "$text" | cut -c1-$(( avail - 3 )))
            out="${out}..."
        fi
        printf '#[fg=#a6e3a1]▶#[fg=#cdd6f4] %s' "$out"
        ;;
    Paused)
        text=$(_track_text "$artist" "$title")
        if [ "$avail" -ge 30 ]; then
            out=$(_marquee "$text" "$avail")
        else
            out=$(printf '%s' "$text" | cut -c1-$(( avail - 3 )))
            out="${out}..."
        fi
        printf '#[fg=#f9e2af]⏸#[fg=#cdd6f4] %s' "$out"
        ;;
    Stopped)
        printf '#[fg=#585b70]● Spotify — Idle'
        ;;
    OFFLINE)
        printf '#[fg=#585b70]● Spotify — Offline'
        ;;
    *)
        printf '#[fg=#585b70]● Spotify — Idle'
        ;;
esac
