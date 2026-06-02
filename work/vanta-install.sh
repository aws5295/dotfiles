#!/usr/bin/env bash
# Vanta-specific install steps — called unconditionally from install.sh,
# but guards internally so steps only run in the right environment.

# ── Jira setup (Gitpod CDEs only) ─────────────────────────────────────────────
if [[ -n "${GITPOD_WORKSPACE_ID:-}" ]]; then
  /home/vscode/.claude/plugins/cache/obsidian-local/jira-operations/1.0.0/skills/jira/scripts/check-setup.sh --fix
fi

# ── obsidian repo: disable devcontainer-only plugins locally (macOS) ──────────
# The ai-env-init plugin runs `sudo tee /etc/bash.bashrc` at every SessionStart,
# which prompts for a password on macOS (passwordless only inside devcontainers).
OBSIDIAN_SETTINGS="$HOME/co/obsidian/.claude/settings.local.json"
if [[ "$(uname)" == "Darwin" ]] && [[ -d "$HOME/co/obsidian/.claude" ]]; then
  python3 - "$OBSIDIAN_SETTINGS" <<'PYEOF'
import json, os, sys

path = sys.argv[1]
settings = {}
if os.path.exists(path):
    with open(path) as f:
        try:
            settings = json.load(f)
        except json.JSONDecodeError:
            pass

plugins = settings.setdefault('enabledPlugins', {})
if plugins.get('ai-env-init@obsidian-local') is not False:
    plugins['ai-env-init@obsidian-local'] = False
    with open(path, 'w') as f:
        json.dump(settings, f, indent=2)
        f.write('\n')
    print('[info] disabled ai-env-init plugin in obsidian settings.local.json')
else:
    print('[info] ai-env-init already disabled, skipping')
PYEOF
fi
