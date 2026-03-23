# ── Completion system ─────────────────────────────────────────────────────────

# Show a menu when there are multiple completions to choose from
zstyle ':completion:*' menu select

# Case-insensitive path completion — typing 'foo' matches 'Foo', 'FOO', etc.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Allow partial completions — e.g. 'n/u/b' expands to 'name/user/bin'
zstyle ':completion:*' list-suffixeszstyle ':completion:*' expand prefix suffix

# Hide internal functions (those starting with _) from completion results
zstyle ':completion:*:functions' ignored-patterns '_*'

# Show a header label above each group of completion results
zstyle ':completion:*' format $'\n%F{yellow}Completing %d%f\n'

# Group completion results by category (files, commands, etc.)
zstyle ':completion:*' group-name ''

# Initialise the completion system (compinit scans fpath for completion functions)
autoload -Uz compinit && compinit

# Enable Shift+Tab to navigate backwards through the completion menu
if [[ -t 1 ]]; then
  zmodload zsh/complist
  bindkey -M menuselect '^[[Z' reverse-menu-complete
fi
