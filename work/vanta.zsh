# -*- mode: sh -*-
# Vanta-specific aliases and functions

# ── Gitpod (cloud desktop) ────────────────────────────────────────────────────
# Commands that should only run on Vanta's Gitpod cloud desktop environment
if [[ -n "$GITPOD_API_URL" ]]; then
  # Load Vanta secrets injected by the Gitpod environment
  [[ -f /etc/profile.d/ona-secrets.sh ]] && source /etc/profile.d/ona-secrets.sh
fi
