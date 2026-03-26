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
