#!/usr/bin/env bash
# Vanta-specific install steps — called unconditionally from install.sh,
# but guards internally so steps only run in the right environment.

# ── Jira setup (Gitpod CDEs only) ─────────────────────────────────────────────
if [[ -n "${GITPOD_WORKSPACE_ID:-}" ]]; then
  /home/vscode/.claude/plugins/cache/obsidian-local/jira-operations/1.0.0/skills/jira/scripts/check-setup.sh --fix
fi
