#!/usr/bin/env bash

layout=""
args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --layout) layout="$2"; shift 2 ;;
    *)        args+=("$1"); shift ;;
  esac
done

if [[ ${#args[@]} -ne 1 ]]; then
  echo "Usage: t <session-name> [--layout <layout>]"
  echo ""
  echo "Sessions:"
  tmux list-sessions 2>/dev/null || echo "  (no sessions running)"
  exit 1
fi

name="${args[0]}"

# If the tmux server has no sessions (e.g. after a CDE restart), attempt to
# restore from tmux-resurrect before falling back to the layout script.
# This preserves manually-added windows and panes across CDE hibernations.
if ! tmux list-sessions &>/dev/null; then
  restore_script="$HOME/.tmux/plugins/tmux-resurrect/scripts/restore.sh"
  if [[ -x "$restore_script" ]]; then
    tmux new-session -d -s _tmux_restore_bootstrap
    "$restore_script" 2>/dev/null
    tmux kill-session -t _tmux_restore_bootstrap 2>/dev/null || true
  fi
fi

if tmux has-session -t "$name" 2>/dev/null; then
  tmux attach -t "$name"
elif [[ -n "$layout" ]]; then
  session_script="$(dirname "$0")/sessions/${layout}.sh"
  if [[ -x "$session_script" ]]; then
    "$session_script" "$name"
  else
    echo "Layout '$layout' not found at $session_script" >&2
    exit 1
  fi
else
  tmux new-session -s "$name"
fi
