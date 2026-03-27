# Shell prompt via Starship — https://starship.rs
# Config: ~/.dotfiles/starship/starship.toml → ~/.config/starship.toml (symlinked by install.sh)
#
# Context (user@<name>) is driven by $DOT_CONTEXT:
#   - Gitpod CDE:     "CDE"           (set in work/vanta.zsh)
#   - Other machines: $DOT_CONTEXT    (set in secrets/local.zsh, fallback to hostname in platform.zsh)
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
