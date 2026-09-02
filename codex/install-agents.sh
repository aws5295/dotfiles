#!/usr/bin/env bash
set -euo pipefail

CODEX_DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CODEX_CONFIG_DIR="$HOME/.codex"
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
AGENTS_SOURCE="$CODEX_DOTFILES_DIR/AGENTS.md"
RTK_SOURCE="$CODEX_DOTFILES_DIR/RTK.md"

install_agent_file() {
  local target="$1"
  local include_rtk="$2"
  local target_dir tmp

  target_dir="$(dirname "$target")"
  mkdir -p "$target_dir"
  tmp="$(mktemp "$target_dir/.agents.XXXXXX")"
  trap 'rm -f "$tmp"' RETURN

  cp "$AGENTS_SOURCE" "$tmp"
  if [[ "$include_rtk" == true ]]; then
    printf '\n@%s\n' "$CODEX_CONFIG_DIR/RTK.md" >> "$tmp"
  fi

  chmod 600 "$tmp"
  mv "$tmp" "$target"
  trap - RETURN
}

mkdir -p "$CODEX_CONFIG_DIR"
ln -sfn "$RTK_SOURCE" "$CODEX_CONFIG_DIR/RTK.md"
install_agent_file "$CODEX_CONFIG_DIR/AGENTS.md" true
install_agent_file "$CLAUDE_CONFIG_DIR/CLAUDE.md" false

echo "[info] shared personal agent instructions installed for Codex and Claude"
