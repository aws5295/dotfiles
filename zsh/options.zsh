# ── Word characters ───────────────────────────────────────────────────────────
# Characters treated as part of a word when using Ctrl+W or alt+backspace.
# Excludes '/' so that path components can be deleted individually.
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# ── History ───────────────────────────────────────────────────────────────────
HISTFILE=$HOME/.zsh_history   # where history is persisted to disk
HISTSIZE=2000000              # number of entries kept in memory
SAVEHIST=2000000              # number of entries saved to disk

setopt append_history         # append to history file rather than overwriting it
setopt extended_history       # record timestamp of each command
setopt share_history          # share history across all open shell sessions
setopt hist_verify            # show the expanded history command before executing it
setopt hist_ignore_all_dups   # if a command is a duplicate, remove the older entry
setopt hist_ignore_space      # don't record commands that start with a space (useful for secrets)

# ── Directory navigation ──────────────────────────────────────────────────────
setopt auto_pushd             # automatically push dirs onto the dir stack when cd-ing
setopt pushd_ignore_dups      # don't push duplicate dirs onto the stack
setopt pushd_silent           # don't print the dir stack after pushd/popd
setopt auto_cd                # type a directory name without 'cd' to navigate to it

# ── Globbing ──────────────────────────────────────────────────────────────────
setopt extended_glob          # enables advanced glob patterns e.g. ^ to negate, # for repetition
unsetopt nomatch              # if a glob has no matches, pass it as-is instead of erroring

# ── Completion ────────────────────────────────────────────────────────────────
setopt menu_complete          # automatically insert the first completion match
