# fzf — fuzzy finder integration for the shell.
# Handles both brew-installed (macOS) and manually installed (~/.fzf) setups.
# Loads shell completion and key bindings when in an interactive terminal.

# Default display options: show results in a 40% height panel, results listed
# top-to-bottom (--reverse), with a border around the panel
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

# Bind ctrl+p to fzf file search (overrides default ctrl+t)
bindkey '^P' fzf-file-widget

_fzf_load_shell_integration() {
  local dir=$1
  # Add fzf's bin to PATH if not already present
  [[ "$PATH" != *"$dir/bin"* ]] && export PATH="$dir/bin:$PATH"
  if [[ -t 1 ]]; then
    # completion.zsh: adds fzf-powered tab completion (e.g. kill <tab>, ssh <tab>)
    [[ -f "$dir/shell/completion.zsh" ]]   && source "$dir/shell/completion.zsh"
    # key-bindings.zsh: binds Ctrl+T (file search), Ctrl+R (history search), Alt+C (cd)
    [[ -f "$dir/shell/key-bindings.zsh" ]] && source "$dir/shell/key-bindings.zsh"
  fi
}

# Brew install (macOS) — fzf installed via Homebrew lives under its prefix
if command -v brew &>/dev/null; then
  local fzf_prefix
  fzf_prefix="$(brew --prefix fzf 2>/dev/null)" || fzf_prefix=""
  if [[ -n "$fzf_prefix" && -d "$fzf_prefix" ]]; then
    _fzf_load_shell_integration "$fzf_prefix"
    return
  fi
fi

# Fallback: manual / git-clone install at ~/.fzf
if [[ -d "$HOME/.fzf" ]]; then
  _fzf_load_shell_integration "$HOME/.fzf"
fi
