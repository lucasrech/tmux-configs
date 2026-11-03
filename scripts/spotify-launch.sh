#!/usr/bin/env bash
# Singleton Spotify pane manager for tmux.
#
# Prefix+s:
#   - If a spotatui pane already exists in the session → switch to it
#   - Otherwise → create a right-side split and start spotatui there
#
# Two-step launch to avoid race condition with set-option -p:
#   1. Create pane with default shell (long-lived → no race)
#   2. Tag the pane while shell is alive (guaranteed to succeed)
#   3. Launch spotatui via send-keys (exec replaces shell → pane closes on exit)

if ! command -v spotatui &>/dev/null; then
    tmux display-message "spotatui não está instalado"
    exit 0
fi

SESSION=$(tmux display-message -p "#{session_name}")

SPOTIFY_PANE=$(
    tmux list-panes -s -t "$SESSION" \
        -F "#{pane_id} #{@pane_role}" 2>/dev/null \
    | awk '$2 == "spotify" { print $1; exit }'
)

if [ -n "$SPOTIFY_PANE" ]; then
    tmux select-pane -t "$SPOTIFY_PANE"
    exit 0
fi

# Create pane with default shell — shell stays alive so set-option wins the race
PANE_ID=$(tmux split-window -h -l 35% -P -F "#{pane_id}" 2>/dev/null)

if [ -z "$PANE_ID" ]; then
    tmux display-message "Erro ao criar pane Spotify"
    exit 1
fi

# Tag while shell is alive (no race condition)
tmux set-option -p -t "$PANE_ID" @pane_role spotify

# Replace shell with spotatui — pane closes automatically when spotatui exits
tmux send-keys -t "$PANE_ID" "exec ~/.config/tmux/scripts/spotify-pane.sh" Enter

exit 0
