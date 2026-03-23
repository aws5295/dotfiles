# ZLE (Zsh Line Editor) — configures how the shell prompt behaves when editing commands.
# Only applied in interactive terminals (skipped in scripts or non-TTY contexts).
[[ -t 1 ]] || return

bindkey -e   # use Emacs-style key bindings (e.g. Ctrl+A = start of line, Ctrl+E = end of line)
             # alternative is -v for vi-style bindings
