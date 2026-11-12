#!/usr/bin/env bash
# Herdr desktop app config — called from install.sh, macOS only (the app runs on the Mac;
# CDEs only run herdr-core). Idempotent: re-run after editing herdr/ or ~/co/herdr-summit.
#
# Symlinks into ~/.config/herdr-app (or $HERDR_APP_HOME):
#   dotfiles/herdr/          keys.json, settings.json, layouts/adam.json, mods/reviewer
#   ~/co/herdr-summit/       mods/summit, layouts/summit.{json,svg}, themes/summit.json (private repo)
# mods/jira is local-only and never tracked; this script leaves it alone.

set -euo pipefail

[[ "$(uname)" == "Darwin" ]] || exit 0

DOTFILES="$(cd "$(dirname "$0")/.." && pwd -P)"
HERDR_HOME="${HERDR_APP_HOME:-$HOME/.config/herdr-app}"
SUMMIT="$HOME/co/herdr-summit"
SUMMIT_REPO="aws5295/herdr-summit"
STAMP="$(date +%Y%m%d%H%M%S)"

warn() { echo "[warn] $*"; }
info() { echo "[info] $*"; }

# Link src -> dest. A real file or folder already at dest (e.g. Herdr saved settings.json
# over the link) is moved aside to dest.bak-<time> so nothing is lost.
link() {
  local src="$1" dest="$2"
  if [[ ! -e "$src" ]]; then warn "herdr: missing $src, skipping"; return; fi
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mv "$dest" "$dest.bak-$STAMP"
    warn "herdr: moved existing $dest to $dest.bak-$STAMP (compare it with $src)"
  fi
  ln -sfn "$src" "$dest"
}

# ── Summit (private repo) ─────────────────────────────────────────────────────
if [[ ! -d "$SUMMIT/.git" ]]; then
  info "cloning $SUMMIT_REPO into $SUMMIT..."
  if command -v gh &>/dev/null && gh auth status &>/dev/null; then
    gh repo clone "$SUMMIT_REPO" "$SUMMIT" -- --quiet || warn "herdr: could not clone $SUMMIT_REPO"
  else
    git clone --quiet "https://github.com/$SUMMIT_REPO.git" "$SUMMIT" \
      || warn "herdr: could not clone $SUMMIT_REPO (private — run 'gh auth login' and re-run install.sh)"
  fi
fi

# ── Links ─────────────────────────────────────────────────────────────────────
info "linking Herdr config into $HERDR_HOME..."
link "$DOTFILES/herdr/keys.json"         "$HERDR_HOME/keys.json"
link "$DOTFILES/herdr/settings.json"     "$HERDR_HOME/settings.json"
link "$DOTFILES/herdr/layouts/adam.json" "$HERDR_HOME/layouts/adam.json"
link "$DOTFILES/herdr/mods/reviewer"     "$HERDR_HOME/mods/reviewer"

if [[ -d "$SUMMIT/.git" ]]; then
  link "$SUMMIT/mods/summit"         "$HERDR_HOME/mods/summit"
  link "$SUMMIT/layouts/summit.json" "$HERDR_HOME/layouts/summit.json"
  link "$SUMMIT/layouts/summit.svg"  "$HERDR_HOME/layouts/summit.svg"
  link "$SUMMIT/themes/summit.json"  "$HERDR_HOME/themes/summit.json"
fi

[[ -d "$HERDR_HOME/mods/jira" ]] || info "herdr: no local mods/jira (Summit's Postcards panel needs it; it isn't tracked)"
