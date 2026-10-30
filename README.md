# tmux-configs

A minimal, pastel-themed tmux environment with contextual pane borders, dual-line system monitoring and an integrated Spotify popup.

![tmux preview](assets/tmux-preview.png)

> `assets/tmux-preview.png` — add a screenshot of your terminal here.

---

## Overview

This is not a stock `.tmux.conf`. It is a self-contained terminal environment built around a few ideas:

- **Context at a glance** — every pane border shows the current path and detects whether you are inside a Docker container or an SSH session, without any manual labeling.
- **System state in the status bar** — two lines at the bottom give you active network interfaces, VPN status, RAM usage and system load alongside the current session and time.
- **No layout disruption** — the Spotify integration uses `display-popup`, so it overlays the current window without touching any pane or split.
- **Keyboard-first** — Vim-style pane navigation and resize, vi copy mode, splits that remember where you are.

Developed and tested on Linux with tmux 3.4.

---

## Features

### Pane borders

Each pane displays its index, current working directory, and an automatically detected context label:

```
 Pane 1 | /home/user/project
 Pane 2 | /home/user/project | Docker: backend
 Pane 3 | /home/user/project | SSH: jetson
```

Detection happens by inspecting the TTY process list — no shell integration required. Docker and SSH labels appear automatically when the foreground process is `docker exec`, `docker attach` or `ssh`.

### Status bar — line 1

```
 PREFIX   main  | 1:bash  2:vim  3:htop                      hostname
```

- `PREFIX` label appears only while the prefix key is held.
- Session name highlighted in blue.
- Window list shows index and name.
- Hostname on the right.

### Status bar — line 2

```
NET eno1 | VPN my-vpn | RAM 8.2Gi/31Gi | LOAD 0.42         25/10/2026 14:32
```

| Field  | Source                        |
|--------|-------------------------------|
| NET    | `nmcli` — active non-loopback interfaces |
| VPN    | `nmcli` — active vpn/wireguard connections |
| RAM    | `free -h` — used/total        |
| LOAD   | `/proc/loadavg` — 1-min average |
| Clock  | Shell date format             |

### Splits and windows

All splits and new windows open in the current pane's working directory. No manual `cd` needed after splitting.

### Other

- True color (RGB) enabled via `terminal-features`
- Mouse support
- Scrollback: 100,000 lines
- Vi keys in copy mode
- Windows and panes numbered from 1
- Windows renumbered automatically on close
- ESC delay reduced to 10 ms

---

## Spotify Integration

`Prefix + s` opens [spotatui](https://github.com/jlucasnsilva/spotatui) in a popup anchored to the upper-right corner of the current window.

```
┌─────────────────────────────────────────────────────────────┐
│                                  ╭──────────────────────╮   │
│                                  │                      │   │
│                                  │      spotatui        │   │
│                                  │                      │   │
│        current workspace         │   now playing        │   │
│                                  │   album art          │   │
│                                  │   controls           │   │
│                                  │                      │   │
│                                  ╰──────────────────────╯   │
└─────────────────────────────────────────────────────────────┘
```

The popup is 45 % wide and 60 % tall. It closes when you quit spotatui, returning focus to where you were. The pane layout is never modified.

If spotatui is not installed, the popup shows a short message with install instructions instead of failing silently.

---

## Theme

Pastel palette on a dark background, close to Catppuccin Mocha.

| Role        | Hex       |
|-------------|-----------|
| Background  | `#1e1e2e` |
| Background 2| `#313244` |
| Gray        | `#585b70` |
| Text        | `#cdd6f4` |
| Text 2      | `#bac2de` |
| Lavender    | `#b4befe` |
| Blue        | `#89b4fa` |
| Cyan        | `#89dceb` |
| Green       | `#a6e3a1` |
| Yellow      | `#f9e2af` |
| Peach       | `#fab387` |
| Pink        | `#f5c2e7` |
| Red         | `#f38ba8` |

Lavender is used for active pane borders. Cyan highlights context labels (Docker, SSH). Blue marks the active session in the status bar.

---

## Keybindings

Prefix: `Ctrl + b`

| Shortcut              | Action                              |
|-----------------------|-------------------------------------|
| `Prefix + c`          | New window (current path)           |
| `Prefix + \|`         | Split horizontal (current path)     |
| `Prefix + -`          | Split vertical (current path)       |
| `Prefix + h/j/k/l`   | Navigate panes                      |
| `Prefix + H/J/K/L`   | Resize panes (5 cells)              |
| `Prefix + r`          | Reload config                       |
| `Prefix + s`          | Open Spotify popup                  |

Standard tmux bindings (`Prefix + "`, `Prefix + %`, mouse, copy mode) remain unchanged.

---

## Installation

**Requirements:** tmux ≥ 3.2, bash.

```bash
git clone https://github.com/lucasrech/tmux-configs.git ~/.config/tmux
chmod +x ~/.config/tmux/scripts/*.sh
```

If tmux is already running:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

Otherwise just start tmux normally:

```bash
tmux
```

### Repository structure

```
~/.config/tmux/
├── tmux.conf
├── scripts/
│   ├── pane-context.sh       # Docker + SSH detection for pane borders
│   ├── pane-container.sh     # standalone Docker detection utility
│   └── spotify-popup.sh      # spotatui launcher with install check
├── assets/
│   └── tmux-preview.png      # (add screenshot here)
└── README.md
```

---

## Dependencies

### Required

| Dependency | Purpose                     |
|------------|-----------------------------|
| `tmux`     | ≥ 3.2 for `display-popup` positioning |
| `bash`     | All scripts use `/usr/bin/env bash` |

### Optional

| Dependency       | Purpose                                              |
|------------------|------------------------------------------------------|
| `nmcli`          | Status bar NET and VPN fields (NetworkManager)       |
| `docker`         | Pane border Docker context label                     |
| `ssh`            | Pane border SSH context label                        |
| `spotatui`       | Spotify TUI — required for `Prefix + s`             |
| `cargo` (Rust)   | To install spotatui: `cargo install spotatui`        |

Everything is gracefully absent when optional dependencies are missing: NET shows `OFF`, VPN shows `OFF`, Docker and SSH labels simply do not appear, and the Spotify popup shows an install hint.

---

## How It Works

### Pane context detection

`pane-context.sh` receives the pane TTY and scans the process list for that terminal:

```
tmux pane (tty)
   │
   ├── docker exec / attach → " | Docker: container-name"
   │
   └── ssh ...              → " | SSH: hostname"
```

It uses `ps -t <tty>` to list processes, then `sed`/`awk` to extract the container name or SSH host. Docker container names are resolved via `docker inspect` to get the canonical name. The output is embedded directly in the pane border format string, polled every `status-interval` seconds.

### Status bar

Line 2 is built entirely from inline shell commands inside `status-format[1]`. No background daemons or external scripts — just `nmcli`, `free`, and `/proc/loadavg` evaluated by tmux at each status refresh (every 2 seconds).

### Spotify popup

`display-popup -E` runs the command in an overlay that shares no pane state with the current window. When the process exits, the overlay closes and the terminal returns to its previous state. `-x R -y 0` anchors the popup to the top-right corner.

---

## Customization

**Spotify popup size and position** — `tmux.conf`, SPOTIFY section:

```
-w 45%   # width relative to window
-h 60%   # height relative to window
-x R     # right edge
-y 0     # top edge
```

**Status bar interval** — adjust `status-interval` (default: 2 seconds).

**Pane border** — `pane-border-format` in `tmux.conf`. The context script call can be removed or extended.

**Colors** — all hex values are defined inline in `tmux.conf` under the `CORES` comment block. No external color file.

**Key bindings** — all bindings are grouped by section in `tmux.conf` with clear comment headers.

---

## Notes

- Developed on Linux; untested on macOS (some `ps` flags and `/proc/loadavg` may differ).
- True color requires a terminal emulator that supports it (most modern ones do).
- No Powerline fonts or special glyphs required — the status bar uses plain ASCII characters.
- `pane-container.sh` is a standalone Docker detection script separate from `pane-context.sh`, which handles both Docker and SSH.
