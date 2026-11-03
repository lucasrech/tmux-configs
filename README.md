<div align="center">

<br/>

<h1>✦ &nbsp; tmux-configs &nbsp; ✦</h1>

<p>
<em>A pastel-dark terminal environment for Linux.</em><br/>
<sub>Contextual pane borders &nbsp;·&nbsp; dual-line system telemetry &nbsp;·&nbsp; integrated Spotify pane</sub>
</p>

<br/>

<img src="assets/tmux-preview.png" alt="tmux preview" width="820"/>

<br/>
<sub><em>↳ Place a terminal screenshot at <code>assets/tmux-preview.png</code> to populate the preview above.</em></sub>
<br/><br/>

[![tmux](https://img.shields.io/badge/tmux-3.4-b4befe?style=flat-square)](https://github.com/tmux/tmux)
&nbsp;
[![Linux](https://img.shields.io/badge/Linux-89b4fa?style=flat-square&logo=linux&logoColor=1e1e2e)](https://kernel.org)
&nbsp;
[![Bash](https://img.shields.io/badge/Bash-a6e3a1?style=flat-square&logo=gnubash&logoColor=1e1e2e)](https://www.gnu.org/software/bash/)
&nbsp;
[![Last Commit](https://img.shields.io/github/last-commit/lucasrech/tmux-configs?style=flat-square&color=f5c2e7)](https://github.com/lucasrech/tmux-configs/commits/master)

<br/>

<sub><em>Not merely a <code>.tmux.conf</code> — a considered environment for those who spend their days in a terminal.</em></sub>

<br/><br/>

</div>

<!-- <p align="center"><img src="assets/divider-rococo.svg" width="100%" alt=""></p> -->

<br/>

## ❦ &nbsp; Overview

This is not a stock `.tmux.conf`. Every part of the visible interface was deliberate: the pane borders read your context without being asked, the status bar draws from live system data rather than static text, and the Spotify overlay appears on command without disturbing a single pane in your layout.

Built around four convictions:

- **Context without ceremony** — Docker containers and SSH sessions surface automatically in the pane border, read from the TTY process list. No shell integration, no plugins.
- **System state at rest** — two status bar lines show active network interfaces, VPN connections, memory usage and load average, updated every two seconds.
- **No layout disruption** — the Spotify pane opens as a non-modal side split. It runs alongside your workspace without blocking other panes or windows.
- **Keyboard-first, mouse-optional** — Vim-style navigation and resize, vi copy mode, and splits that inherit the current path. Mouse enabled for when you want it.

Developed and tested on Linux with tmux 3.4.

<br/>

<!-- <p align="center"><img src="assets/divider-floral.svg" width="100%" alt=""></p> -->

<br/>

## ✦ &nbsp; Features

| &nbsp; | Feature | Description |
|:---:|---|---|
| ❖ | **Pane Context** | Docker and SSH detection via TTY process inspection |
| ✦ | **Status Bar** | Two-line bar: session/windows above, telemetry below |
| ❦ | **Spotify Pane** | spotatui singleton side-pane, <kbd>Prefix</kbd>&nbsp;+&nbsp;<kbd>s</kbd> |
| ⟡ | **Navigation** | Vim-style pane movement and resize |
| ✾ | **True Color** | RGB support via `terminal-features` |
| ❧ | **Path Inheritance** | Splits and new windows open at the current path |

<br/>

### Pane Borders

Each pane border displays its index, working directory, and — when relevant — a detected context label:

```
 Pane 1 | /home/user/project
 Pane 2 | /home/user/project  | Docker: backend
 Pane 3 | /home/user/project  | SSH: jetson
```

Labels appear when the foreground process is `docker exec`, `docker attach`, or `ssh`. No configuration needed. When none of those are active, the border shows only the path.

<br/>

### Status Bar

```
╭──────────────────────────────────────────────────────────────────╮
│  PREFIX   main  │ 1:bash  2:docker  3:ssh              hostname  │
├──────────────────────────────────────────────────────────────────┤
│  NET eno1 │ VPN my-vpn │ RAM 8.2Gi/31Gi │ LOAD 0.42             │
│                                           25/10/2026    14:32   │
╰──────────────────────────────────────────────────────────────────╯
```

**Line 1** — `PREFIX` indicator (visible only while the prefix key is held) · session name · window list · hostname aligned right.

**Line 2** — system telemetry drawn from live shell commands, refreshed every 2 seconds:

| Field | Source | When absent |
|---|---|---|
| NET | `nmcli` — connected non-loopback interfaces | `OFF` |
| VPN | `nmcli` — active vpn/wireguard connections | `OFF` |
| RAM | `free -h` — used / total | — |
| LOAD | `/proc/loadavg` — 1-minute average | — |
| ♪ Track | `playerctl` via MPRIS — current spotatui track | hidden |
| Clock | `%d/%m/%Y` and `%H:%M` | — |

<br/>

### Other

- Scrollback: 100,000 lines
- Vi keys in copy mode
- Windows and panes numbered from 1; windows renumbered on close
- ESC delay: 10 ms
- Mouse: enabled
- Bell: disabled

<br/>

<!-- <p align="center"><img src="assets/divider-rococo.svg" width="100%" alt=""></p> -->

<br/>

## ❖ &nbsp; Spotify Integration

<kbd>Prefix</kbd> + <kbd>s</kbd> opens **spotatui** in a right-side pane (35 % of window width). The rest of the window remains fully interactive — other panes are never blocked.

```
╔═════════════════════════════════════════════════════════════════╗
║                                    │  ✦  spotatui  ✦    ║     ║
║                                    │                     ║     ║
║        current workspace           │   now playing       ║     ║
║                                    │   album art         ║     ║
║                                    │   ◀  ▐▐  ▶  ●──○  ║     ║
║                                    │                     ║     ║
╚═════════════════════════════════════════════════════════════════╝
```

**Singleton**: pressing <kbd>Prefix</kbd> + <kbd>s</kbd> while spotatui is already open switches focus to the existing pane rather than opening a second instance. This prevents the 404/410 native playback errors that arise when multiple instances register competing `device_id`s with the Spotify API.

**Closing**: press <kbd>q</kbd> inside spotatui to exit — the pane closes automatically.

**Media controls** (require `playerctl` — `sudo apt install playerctl`):

| Shortcut | Action |
|---|---|
| <kbd>Prefix</kbd> + <kbd>B</kbd> | Previous track |
| <kbd>Prefix</kbd> + <kbd>P</kbd> | Play / Pause |
| <kbd>Prefix</kbd> + <kbd>N</kbd> | Next track |

**Status bar**: when spotatui is playing, the current track appears in status bar line 2:

```
NET eno1 | VPN OFF | RAM 3.1G/16G | LOAD 0.42 | ♪ Artist - Title
```

Track info is drawn via MPRIS/playerctl and hidden when nothing is playing. Truncated at 40 characters.

If spotatui is not installed, <kbd>Prefix</kbd> + <kbd>s</kbd> displays a message rather than failing silently.

<br/>

<!-- <p align="center"><img src="assets/divider-rococo.svg" width="100%" alt=""></p> -->

<br/>

## ⟡ &nbsp; Theme

Pastel palette on a deep background, close to Catppuccin Mocha. All values are defined inline in `tmux.conf`.

| Role | Hex | Purpose |
|---|---|---|
| Background | `#1e1e2e` | Window and status bar background |
| Background 2 | `#313244` | Message and command prompt background |
| Gray | `#585b70` | Inactive pane borders, status separators |
| Text | `#cdd6f4` | Primary text |
| Text 2 | `#bac2de` | Inactive window names |
| Lavender | `#b4befe` | Active pane border |
| Blue | `#89b4fa` | Active window highlight |
| Cyan | `#89dceb` | NET label, clock, context indicators |
| Green | `#a6e3a1` | VPN label |
| Yellow | `#f9e2af` | RAM label, message style |
| Peach | `#fab387` | LOAD label |
| Pink | `#f5c2e7` | Date in status bar |
| Red | `#f38ba8` | Defined in palette |

<br/>

<!-- <p align="center"><img src="assets/divider-floral.svg" width="100%" alt=""></p> -->

<br/>

## ❧ &nbsp; Keybindings

Prefix: <kbd>Ctrl</kbd> + <kbd>b</kbd>

| Shortcut | Action |
|---|---|
| <kbd>Prefix</kbd> + <kbd>c</kbd> | New window at current path |
| <kbd>Prefix</kbd> + <kbd>\|</kbd> | Split horizontal at current path |
| <kbd>Prefix</kbd> + <kbd>-</kbd> | Split vertical at current path |
| <kbd>Prefix</kbd> + <kbd>h</kbd> / <kbd>j</kbd> / <kbd>k</kbd> / <kbd>l</kbd> | Navigate panes |
| <kbd>Prefix</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> | Resize panes (5 cells) |
| <kbd>Prefix</kbd> + <kbd>r</kbd> | Reload configuration |
| <kbd>Prefix</kbd> + <kbd>s</kbd> | Open / focus Spotify pane |
| <kbd>Prefix</kbd> + <kbd>B</kbd> | Spotify: previous track |
| <kbd>Prefix</kbd> + <kbd>P</kbd> | Spotify: play / pause |
| <kbd>Prefix</kbd> + <kbd>N</kbd> | Spotify: next track |

Standard tmux bindings — <kbd>Prefix</kbd> + <kbd>"</kbd>, <kbd>Prefix</kbd> + <kbd>%</kbd>, mouse, copy mode — remain unchanged.

<br/>

<!-- <p align="center"><img src="assets/divider-rococo.svg" width="100%" alt=""></p> -->

<br/>

## ✦ &nbsp; Installation

**Requirements:** tmux ≥ 3.2, bash.

```bash
git clone https://github.com/lucasrech/tmux-configs.git ~/.config/tmux
chmod +x ~/.config/tmux/scripts/*.sh
```

If tmux is already running, reload without restarting:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

Or, from inside a tmux session: <kbd>Prefix</kbd> + <kbd>r</kbd>.

<br/>

**Repository structure**

```
~/.config/tmux/
├── tmux.conf
├── scripts/
│   ├── pane-context.sh        Docker + SSH detection for pane borders
│   ├── pane-container.sh      standalone Docker detection utility
│   ├── spotify-launch.sh      singleton pane manager (Prefix+s)
│   └── status-spotify.sh      MPRIS track info for status bar line 2
├── assets/
│   ├── divider-rococo.svg
│   ├── divider-floral.svg
│   ├── divider-small.svg
│   └── tmux-preview.png       (add a terminal screenshot here)
└── README.md
```

<br/>

<!-- <p align="center"><img src="assets/divider-small.svg" width="100%" alt=""></p> -->

<br/>

## ❖ &nbsp; Dependencies

### Required

| Dependency | Purpose |
|---|---|
| `tmux` ≥ 3.0 | pane user options (`set-option -p @name`) for singleton tracking |
| `bash` | All scripts target `/usr/bin/env bash` |

### Optional

| Dependency | Purpose |
|---|---|
| `nmcli` | NET and VPN fields in the status bar (NetworkManager) |
| `docker` | Docker context label in pane borders |
| `ssh` | Pane border SSH context label |
| `spotatui` | Spotify TUI — required for <kbd>Prefix</kbd> + <kbd>s</kbd> |
| `cargo` (Rust) | To install spotatui: `cargo install spotatui` |
| `playerctl` | Media controls and status bar track info — `sudo apt install playerctl` |

All optional dependencies degrade gracefully: NET and VPN fall back to `OFF`, context labels do not appear, the Spotify pane shows an install hint, and track info is simply hidden when playerctl is absent.

<br/>

<!-- <p align="center"><img src="assets/divider-small.svg" width="100%" alt=""></p> -->

<br/>

## ⟡ &nbsp; How It Works

### Pane context detection

`pane-context.sh` receives the pane TTY path and interrogates the process table:

```
pane TTY
   │
   ├─ ps -t <tty>
   │      │
   │      ├─ docker exec / attach ──► docker inspect ──► " | Docker: name"
   │      │
   │      └─ ssh ...               ──► parse flags/args ─► " | SSH: host"
   │
   └─ (no match) ──► no label appended
```

Docker container names are resolved via `docker inspect` to retrieve the canonical name rather than the runtime ID passed on the command line. SSH host extraction parses the argument list, skipping all known flags and their values.

The output is embedded directly in `pane-border-format` and polled at each `status-interval` tick.

### Status bar

Line 2 (`status-format[1]`) contains inline shell commands evaluated by tmux at each refresh. No external scripts, no daemons: just `nmcli`, `free -h`, and a read from `/proc/loadavg`, run in-process every 2 seconds.

### Spotify pane

`spotify-launch.sh` is called via `run-shell` on `Prefix+s`. It queries `list-panes -s` for a pane tagged with the tmux user option `@pane_role=spotify`. If found, it calls `select-pane` on it (idempotent). If not, it creates a new pane with `split-window -h -l 35%`, captures the pane ID via `-P -F "#{pane_id}"`, and sets `@pane_role spotify` on it. When spotatui exits (`q`), the pane closes and the user option disappears — no cleanup needed.

`status-spotify.sh` calls `playerctl -p spotatui metadata --format '{{status}}|{{artist}} - {{title}}'` in a single invocation. Output is empty when playerctl is absent, spotatui is not running, or playback is stopped. The resulting string includes tmux color directives (`#[fg=color]`) which the status-format parser processes inline.

<br/>

## ❧ &nbsp; Customization

**Spotify pane width** — `split-window -h -l 35%` in `spotify-launch.sh`. Change `35%` to any value.

**Status bar refresh rate** — `set -g status-interval` (default: `2`). Affects how often the track name updates.

**Pane border** — `pane-border-format` in `tmux.conf`. The context script call can be replaced or extended with additional detectors.

**Colors** — all hex values are defined inline in `tmux.conf` under the `# CORES` block. No external theme file.

**Key bindings** — each binding group has its own labeled section in `tmux.conf`.

<br/>

## ✦ &nbsp; Notes

- Developed and tested on Linux. macOS compatibility is untested; `ps` flag syntax and `/proc/loadavg` differ on Darwin.
- True color requires a terminal emulator that supports it. Most modern emulators do.
- No Powerline fonts or Nerd Font glyphs are required. The status bar uses plain text.
- `pane-container.sh` is a standalone Docker detection script independent of `pane-context.sh`. The pane border uses `pane-context.sh`, which covers both Docker and SSH.

<br/>

<!-- <p align="center"><img src="assets/divider-rococo.svg" width="100%" alt=""></p> -->

<br/>

<div align="center">

<sub>
❦ &nbsp; Built for Linux, pastel colors, and the kind of tmux configuration<br/>
that quietly judges every terminal that isn't it. &nbsp; ❦
</sub>

<br/>

<sub><a href="https://github.com/lucasrech/tmux-configs">lucasrech/tmux-configs</a> &nbsp;·&nbsp; tmux 3.4 &nbsp;·&nbsp; Linux</sub>

</div>
