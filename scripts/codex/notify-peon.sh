#!/usr/bin/env bash
set -uo pipefail

# Codex calls this command from `notify` with an optional event argument and a
# JSON payload on stdin. peon-ping already ships a Codex adapter, so this wrapper
# finds it without hard-coding one Homebrew version.

event="${1:-}"
payload=""
if [[ ! -t 0 ]]; then
  payload="$(cat)"
fi

adapter_candidates=(
  "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/peon-ping/adapters/codex.sh"
  "${CODEX_HOME:-$HOME/.codex}/hooks/peon-ping/adapters/codex.sh"
  "/opt/homebrew/opt/peon-ping/libexec/adapters/codex.sh"
  "/usr/local/opt/peon-ping/libexec/adapters/codex.sh"
)

for adapter in "${adapter_candidates[@]}"; do
  if [[ -f "$adapter" ]]; then
    printf '%s' "$payload" | bash "$adapter" "$event"
    exit 0
  fi
done

# No adapter means this machine has Codex configured but peon-ping is not
# installed or not set up for shell hooks. Notifications should never block
# Codex, so exit successfully.
exit 0
