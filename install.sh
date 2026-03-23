#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# --non-interactive flag: skips prompts (used for cloud/provisioned machines like Gitpod)
INTERACTIVE=true
for arg in "$@"; do
  [[ "$arg" == "--non-interactive" ]] && INTERACTIVE=false
done

warn() { echo "[warn] $*"; }
info() { echo "[info] $*"; }
die()  { echo "[error] $*" >&2; exit 1; }

# ── Pre-flight checks ─────────────────────────────────────────────────────────
# Fail fast if hard dependencies are missing before doing any work
command -v git  &>/dev/null || die "git is required but not installed"
command -v curl &>/dev/null || die "curl is required but not installed"
if [[ "$(uname)" == "Darwin" ]]; then
  command -v brew &>/dev/null || die "Homebrew is required on macOS — install from https://brew.sh"
fi

# ── Git local config ──────────────────────────────────────────────────────────
# ~/.gitconfig.local holds the machine-specific git email and is never committed.
# In interactive mode we prompt for it on first run. On provisioned machines
# (e.g. Gitpod) the email is already injected by the platform, so we skip this.
if [[ ! -f ~/.gitconfig.local ]]; then
  if [[ "$INTERACTIVE" == true ]]; then
    printf "Git email for this machine: "
    read -r git_email
    printf "[user]\n  email = %s\n" "$git_email" > ~/.gitconfig.local
    info "created ~/.gitconfig.local with email: $git_email"
  else
    warn "skipping ~/.gitconfig.local creation in non-interactive mode"
  fi
else
  info "~/.gitconfig.local already exists, skipping"
fi

# ── Homebrew packages ─────────────────────────────────────────────────────────
# Install everything listed in Brewfile. brew bundle is idempotent — safe to re-run.
if command -v brew &>/dev/null; then
  info "installing brew packages..."
  brew bundle --file="$DOTFILES/Brewfile"
else
  warn "brew not found — skipping Brewfile install"
fi

# ── Symlinks ──────────────────────────────────────────────────────────────────
# Symlink config files into the locations each tool expects.
# -sfn: create symbolic link, force overwrite, and don't nest if target is a dir.
info "creating symlinks..."
ln -sfn "$DOTFILES/zsh/main.zsh"    ~/.zshrc        # zsh entry point
ln -sfn "$DOTFILES/zsh"             ~/.zsh.d         # zsh config dir
ln -sfn "$DOTFILES/zsh/zshenv.zsh"  ~/.zshenv        # zsh env vars (loaded for all zsh instances)
ln -sfn "$DOTFILES/tmux/main.tmux"  ~/.tmux.conf     # tmux entry point
ln -sfn "$DOTFILES/tmux"            ~/.tmux.d         # tmux config dir
ln -sfn "$DOTFILES/vim"             ~/.vim            # vim config dir
ln -sfn "$DOTFILES/git/gitconfig"   ~/.gitconfig     # git config
ln -sfn "$DOTFILES/ag/ignore"       ~/.ignore        # ag/ripgrep ignore patterns
ln -sfn "$DOTFILES"                 ~/.dotfiles       # convenience pointer to this repo

# VSCode settings and the press-and-hold fix are only applied if VSCode is installed.
# Settings path differs by OS: macOS uses ~/Library/..., Linux uses ~/.config/...
if command -v code &>/dev/null; then
  # Disable macOS press-and-hold accent picker so vim key repeat (j/k) works in VSCode
  if [[ "$(uname)" == "Darwin" ]]; then
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
  fi
  if [[ "$(uname)" == "Darwin" ]]; then
    ln -sfn "$DOTFILES/vscode/settings.json" ~/Library/Application\ Support/Code/User/settings.json
  elif [[ "$(uname)" == "Linux" ]]; then
    mkdir -p ~/.config/Code/User
    ln -sfn "$DOTFILES/vscode/settings.json" ~/.config/Code/User/settings.json
  fi
else
  warn "code not found — skipping VSCode settings symlink"
fi

# ── Zsh plugins ───────────────────────────────────────────────────────────────
# Clone third-party zsh plugins into deps/zsh/. Skips any that already exist.
# Plugins are sourced from main.zsh at shell startup.
info "cloning zsh plugins..."
clone_dep() {
  local dest="$DOTFILES/deps/zsh/$1"
  if [ -d "$dest" ]; then
    info "  $1 already exists, skipping"
  else
    git clone --depth 1 "https://github.com/$1" "$dest"
  fi
}
clone_dep "zsh-users/zsh-autosuggestions"           # suggests commands as you type based on history
clone_dep "zsh-users/zsh-completions"               # additional completion definitions
clone_dep "zdharma-continuum/fast-syntax-highlighting" # syntax highlighting in the shell prompt
clone_dep "wfxr/forgit"                             # interactive git commands via fzf

# ── Vim-plug ──────────────────────────────────────────────────────────────────
# Download the vim-plug plugin manager. Vim plugins themselves are installed
# automatically on first `vim` open via the VimEnter autocmd in vim/plugins.vim.
if command -v vim &>/dev/null; then
  info "downloading vim-plug..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  info "vim plugins will install automatically on first 'vim' open"
else
  warn "vim not found — skipping vim-plug install"
fi

# ── TPM (tmux plugin manager) ─────────────────────────────────────────────────
# Clone TPM into ~/.tmux/plugins/tpm. After install, open tmux and press
# Ctrl+A I to install the plugins defined in tmux/plugins.tmux.
if command -v tmux &>/dev/null; then
  if [ ! -d ~/.tmux/plugins/tpm ]; then
    info "installing TPM..."
    git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  else
    info "TPM already installed, skipping"
  fi
else
  warn "tmux not found — skipping TPM install"
fi

# ── VSCode extensions ──────────────────────────────────────────────────────────
# Install all extensions listed in vscode/extensions (one ID per line, # comments ignored).
if command -v code &>/dev/null; then
  info "installing VSCode extensions..."
  grep -v '^\s*#' "$DOTFILES/vscode/extensions" | grep -v '^\s*$' | while read -r ext; do
    code --install-extension "$ext" --force
  done
else
  warn "code not found — skipping VSCode extensions"
fi

info "done. open a new shell or run: exec zsh"
