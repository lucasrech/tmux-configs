#!/usr/bin/env bash
# Singleton Spotify pane manager for tmux.
#
# Prefix+s:
#   - If a spotatui pane already exists in the session → switch to it
#   - Otherwise → create a right-side split and start spotatui there
#
# The pane is tagged with @pane_role=spotify so it can be located
# without relying on pgrep (which would match external instances).

if ! command -v spotatui &>/dev/null; then
    tmux display-message "spotatui não está instalado"
    exit 0
fi

SESSION=$(tmux display-message -p "#{session_name}")

# Look for an existing spotify pane in the current session
SPOTIFY_PANE=$(
    tmux list-panes -s -t "$SESSION" \
        -F "#{pane_id} #{@pane_role}" 2>/dev/null \
    | awk '$2 == "spotify" { print $1; exit }'
)

if [ -n "$SPOTIFY_PANE" ]; then
    # Already running — focus it, do not start another instance
    tmux select-pane -t "$SPOTIFY_PANE"
    exit 0
fi

# Create a horizontal split (right side, 35% of window width).
# exec spotatui: pane closes automatically when spotatui exits (q).
# -P -F prints the new pane ID for tagging.
PANE_ID=$(
    tmux split-window -h -l 35% \
        -P -F "#{pane_id}" \
        "exec spotatui" 2>/dev/null
)

if [ -z "$PANE_ID" ]; then
    tmux display-message "Erro ao criar pane do Spotify"
    exit 1
fi

# Tag the pane with a user option (tmux 3.0+).
# This tag disappears when the pane closes — no stale state.
tmux set-option -p -t "$PANE_ID" @pane_role spotify
