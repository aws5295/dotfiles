#!/usr/bin/env bash
# Web/vanta session layout
set -euo pipefail
SESSION="${1:-web}"

# Window 1: git — pull and create a branch named after the session
tmux new-session -d -s "$SESSION" -n "git"
tmux send-keys -t "$SESSION:git" "git pull origin main" Enter

# Window 2: shell
tmux new-window -t "$SESSION" -n "shell"
tmux send-keys -t "$SESSION:shell" "gh auth login" Enter

# Window 3: claude
tmux new-window -t "$SESSION" -n "claude"
tmux send-keys -t "$SESSION:claude" "claude" Enter

# Window 4: web — 60/40 left/right split; run "just pp" in the left pane
tmux new-window -t "$SESSION" -n "web"
tmux split-window -h -l 40% -t "$SESSION:web"
tmux send-keys -t "$SESSION:web.0" "just pp" Enter

# Window 5: docker
tmux new-window -t "$SESSION" -n "docker"
tmux send-keys -t "$SESSION:docker" "lazydocker" Enter

# Focus the git window on attach
tmux select-window -t "$SESSION:git"
tmux attach -t "$SESSION"
