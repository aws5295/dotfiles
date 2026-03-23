# -*- mode: sh -*-

# ── Core ──────────────────────────────────────────────────────────────────────
source ~/.zsh.d/options.zsh
source ~/.zsh.d/termcolors.zsh
source ~/.zsh.d/zleconfig.zsh
source ~/.zsh.d/functions.zsh

# ── Aliases ───────────────────────────────────────────────────────────────────
source ~/.zsh.d/aliases.zsh

# ── Prompt ────────────────────────────────────────────────────────────────────
source ~/.zsh.d/prompt.zsh

# ── Platform (macOS / Linux) ──────────────────────────────────────────────────
source ~/.zsh.d/platform.zsh

# ── Plugins ───────────────────────────────────────────────────────────────────
local deps=~/.dotfiles/deps/zsh

fpath=($deps/zsh-users/zsh-completions/src $fpath)

if [[ -t 1 ]]; then
  [[ -f $deps/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source $deps/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh

  [[ -f $deps/zdharma-continuum/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && \
    source $deps/zdharma-continuum/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
fi

[[ -f $deps/wfxr/forgit/forgit.plugin.zsh ]] && \
  source $deps/wfxr/forgit/forgit.plugin.zsh

# ctrl+space: accept next word of suggestion; ctrl+z: accept full suggestion
if [[ -t 1 ]]; then
  bindkey '^ ' forward-word
  bindkey '^Z' autosuggest-accept
fi

# ── Completions ───────────────────────────────────────────────────────────────
source ~/.zsh.d/completions.zsh

# ── fzf ───────────────────────────────────────────────────────────────────────
source ~/.zsh.d/fzf.zsh

# ── dircolors ─────────────────────────────────────────────────────────────────
if command -v dircolors &>/dev/null && [[ -f ~/.lscolors ]]; then
  eval $(dircolors ~/.lscolors)
fi

# ── direnv ────────────────────────────────────────────────────────────────────
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# ── Secrets ───────────────────────────────────────────────────────────────────
# Local secrets file — gitignored, never committed. Copy secrets/example.zsh to
# secrets/local.zsh and fill in values. See secrets/example.zsh for available vars.
[[ -f ~/.dotfiles/secrets/local.zsh ]] && source ~/.dotfiles/secrets/local.zsh

# ── Work (employer-specific) ──────────────────────────────────────────────────
for f in ~/.dotfiles/work/*.zsh; do
  [[ -f "$f" ]] && source "$f"
done
