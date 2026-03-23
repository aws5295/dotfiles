# dotfiles

Personal dotfiles for **M1 Mac** and **Linux CDEs** (no sudo required).

## What's included

| Area | Config |
|---|---|
| Shell | zsh — aliases, functions, fzf, autosuggestions, syntax highlighting, forgit |
| Editor | vim — vim-plug, gruvbox theme, fzf integration |
| Multiplexer | tmux — Dracula theme, TPM, session restore |
| Git | gitconfig — diff-so-fancy, useful aliases |
| Search | ag (The Silver Searcher) |

## Install

```sh
git clone https://github.com/aws5295/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` does the following (no sudo required):

1. Creates symlinks (`~/.zshrc`, `~/.tmux.conf`, `~/.vim`, `~/.gitconfig`, etc.)
2. Clones zsh plugins into `deps/zsh/`
3. Downloads [vim-plug](https://github.com/junegunn/vim-plug) — **plugins install on first `vim` open** (run `:PlugInstall` manually if they don't)
4. Installs [TPM](https://github.com/tmux-plugins/tpm) — **tmux plugins install on first tmux start** after pressing `Ctrl-A + I`

If `vim` or `tmux` aren't installed on the machine, those steps are skipped with a warning.

## Prerequisites

**macOS:** [Homebrew](https://brew.sh) must be installed. All other tools are installed automatically from `Brewfile` when you run `install.sh`.

**Linux CDE:** `git` and `curl` must be available. Tool installation via Homebrew is skipped on Linux — install `zsh`, `vim`, `tmux`, and `fzf` via your package manager or CDE provider before running `install.sh`.

## Post-install

**Vim plugins:** Open vim and run `:PlugInstall`, then restart vim.

**Tmux plugins:** Start tmux and press `Ctrl-A + I` to install TPM plugins.

**iTerm2 font:** The tmux Dracula theme uses powerline symbols that require a Nerd Font. After `install.sh` runs, set the font in iTerm2:
> Preferences → Profiles → Text → Font → **JetBrainsMono Nerd Font**

**iTerm2 theme:** Follow the setup instructions at [draculatheme.com/iterm](https://draculatheme.com/iterm) to apply the Dracula color scheme to iTerm2.

## Verification

```sh
# Shell loads cleanly
zsh -i -c "exit"

# Vim plugins installed
vim +PlugStatus +q

# Tmux config loads
tmux new-session -d && tmux kill-server

# Git pager works
git log --oneline
```

## Structure

```
dotfiles/
├── install.sh          # bootstrap: symlinks + plugin install
├── zsh/
│   ├── main.zsh        # entry point (~/.zshrc)
│   ├── aliases.zsh     # all aliases (general, git, docker, vim)
│   ├── functions.zsh   # shell functions (s, sk, md, =)
│   ├── options.zsh     # shell options (history, navigation)
│   ├── completions.zsh # zsh completion system
│   ├── prompt.zsh      # prompt
│   ├── fzf.zsh         # fzf integration
│   ├── platform.zsh    # macOS vs Linux PATH setup
│   └── termcolors.zsh  # ANSI color variables
├── tmux/               # tmux config (TPM, Dracula, resurrect)
├── vim/                # vim config (vim-plug, gruvbox)
├── git/                # gitconfig
├── ag/                 # .ignore file for ag
└── deps/               # cloned plugin dependencies (gitignored)
```

## Updating plugins

```sh
# Zsh plugins
cd ~/.dotfiles
for d in deps/zsh/*/*; do git -C "$d" pull; done

# Vim plugins
vim +PlugUpdate +qall

# Tmux plugins
# prefix + U inside tmux
```
