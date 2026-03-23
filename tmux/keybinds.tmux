# -*- mode: sh -*-

# ── Vi mode ───────────────────────────────────────────────────────────────────
# Use vi-style keys in the status bar command prompt
set-option -g status-keys vi
# Use vi-style keys when scrolling/selecting in copy mode (Ctrl+A Space to enter)
setw -g mode-keys vi
# Remove the delay after pressing Escape (default 500ms delay breaks vim inside tmux)
set -sg escape-time 0

# ── Prefix key ────────────────────────────────────────────────────────────────
# Change the prefix from the default Ctrl+B to Ctrl+A (easier to reach)
unbind C-b
set -g prefix C-a

# ── Window navigation ─────────────────────────────────────────────────────────
# Prefix + p: jump back to the previously active window
bind-key p last-window

# Prefix + Space: enter copy/scroll mode
bind Space copy-mode

# Prefix + r: cycle through tmux's built-in pane layouts (even-horizontal, tiled, etc.)
bind r next-layout

# ── Pane navigation (vim-style) ───────────────────────────────────────────────
# Prefix + h/j/k/l: move focus between panes (left/down/up/right)
# -r flag means the key can be repeated without pressing prefix again
bind-key -r h select-pane -L
bind-key -r j select-pane -D
bind-key -r k select-pane -U
bind-key -r l select-pane -R

# ── Pane splitting ────────────────────────────────────────────────────────────
# Prefix + |: split pane vertically (side by side)
bind-key | split-window -h
# Prefix + -: split pane horizontally (one above the other)
bind-key - split-window -v

# ── Pane resizing ─────────────────────────────────────────────────────────────
# Prefix + arrow keys: resize panes in 5-cell increments
bind-key Left  resize-pane -L 5
bind-key Right resize-pane -R 5
bind-key Up    resize-pane -U 5
bind-key Down  resize-pane -D 5

# ── Mouse support ─────────────────────────────────────────────────────────────
# Enable mouse by default (click to select panes, scroll, resize)
set -g mouse
# Prefix + m: toggle mouse support on/off
bind-key m set -g mouse

# ── Config reload ─────────────────────────────────────────────────────────────
# Prefix + r: reload tmux config without restarting
bind r source ~/.tmux.conf

# ── Function key bindings (no prefix needed) ──────────────────────────────────
bind -n F9  next-layout       # cycle through pane layouts
bind -n F11 set -g mouse      # toggle mouse support
bind -n F12 set status        # toggle the tmux status bar on/off

# ── Pane switching without prefix (Alt+arrow) ────────────────────────────────
bind -n M-Left  select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up    select-pane -U
bind -n M-Down  select-pane -D

# ── Pane splitting without prefix (Ctrl+Alt+arrow) ───────────────────────────
bind -n C-M-Left  split-window -h
bind -n C-M-Right split-window -h
bind -n C-M-Up    split-window -v
bind -n C-M-Down  split-window -v
