# ZLE (Zsh Line Editor) — configures how the shell prompt behaves when editing commands.
# Only applied in interactive terminals (skipped in scripts or non-TTY contexts).
[[ -t 1 ]] || return

bindkey -v   # vi-style key bindings (insert mode by default, Esc/jk to enter normal mode)

# jk: exit insert mode (mirrors the vim mapping in keybinds.vim)
bindkey -M viins 'jk' vi-cmd-mode

# ── Cursor shape ──────────────────────────────────────────────────────────────
# Beam cursor in insert mode, block cursor in normal mode.
# Uses the same tmux-aware escape sequences as vim/cursorshape.vim.
_zsh_cursor_beam()  {
  [[ -n $TMUX ]] && printf '\ePtmux;\e\e[6 q\e\\' || printf '\e[6 q'
}
_zsh_cursor_block() {
  [[ -n $TMUX ]] && printf '\ePtmux;\e\e[2 q\e\\' || printf '\e[2 q'
}

# Switch shape when moving between insert and normal mode
zle-keymap-select() {
  [[ $KEYMAP == vicmd ]] && _zsh_cursor_block || _zsh_cursor_beam
}
zle -N zle-keymap-select

# Beam at the start of each new prompt (always begin in insert mode)
# Block when a command runs (not in the line editor)
autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-init   _zsh_cursor_beam
add-zle-hook-widget zle-line-finish _zsh_cursor_block
