# -*- mode: sh -*-

# Don't let tmux rename tabs automatically when the running process changes
set-option -g allow-rename off

# Tell tmux which shell to use for new windows/panes
def_shell=/bin/zsh
set-option -g default-shell $def_shell

# Number windows starting from 1 instead of 0 (easier to reach on keyboard)
set -g base-index 1

# Show the status bar
set -g status on

# Increase the scrollback buffer (default is 2000 lines)
set -g history-limit 30000

# When a window is closed, renumber remaining windows so there are no gaps
set-option -g renumber-windows on

# Pass extended key sequences (e.g. Shift+Enter) through to applications like Claude Code
set -g extended-keys on
