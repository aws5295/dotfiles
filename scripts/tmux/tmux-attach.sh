#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
  echo "Usage: t <session-name>  # connects to session if it exists, otherwise creates it"
  echo ""
  echo "Sessions:"
  tmux list-sessions 2>/dev/null || echo "  (no sessions running)"
  exit 1
fi

name="$1"

if tmux has-session -t "$name" 2>/dev/null; then
  tmux attach -t "$name"
else
  tmux new-session -s "$name"
fi
