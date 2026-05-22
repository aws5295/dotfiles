#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd -P)"

# Detect interactive mode: check for explicit flag or whether stdin is a TTY.
# On provisioned machines (e.g. Gitpod) stdin is not a TTY, so prompts are skipped automatically.
INTERACTIVE=true
for arg in "$@"; do
  [[ "$arg" == "--non-interactive" ]] && INTERACTIVE=false
done
[[ ! -t 0 ]] && INTERACTIVE=false

warn() { echo "[warn] $*"; }
info() { echo "[info] $*"; }
die()  { echo "[error] $*" >&2; exit 1; }

# shellcheck source=/dev/null
source "$DOTFILES/scripts/editor_extensions.sh"

patch_codex_config() {
  local config="$HOME/.codex/config.toml"
  local tmp

  mkdir -p "$(dirname "$config")"
  touch "$config"
  tmp="$(mktemp)"

  awk '
    function print_managed_block() {
      print "model = \"gpt-5.5\""
      print "model_reasoning_effort = \"high\""
      print "project_root_markers = [\".git\", \"package.json\", \"pnpm-workspace.yaml\", \"yarn.lock\", \"tsconfig.json\", \"MAINTAINERS\", \"Brewfile\"]"
      print "notify = [\"bash\", \"-lc\", \"exec \\\"$HOME/.dotfiles/scripts/codex/notify-peon.sh\\\"\"]"
      print ""
      inserted = 1
    }

    BEGIN {
      inserted = 0
      in_top_level = 1
    }

    in_top_level && $0 ~ /^[[:space:]]*\[/ {
      if (!inserted) {
        print_managed_block()
      }
      in_top_level = 0
      print
      next
    }

    in_top_level && $0 ~ /^[[:space:]]*(model|model_reasoning_effort|project_root_markers|notify)[[:space:]]*=/ {
      next
    }

    { print }

    END {
      if (in_top_level && !inserted) {
        print_managed_block()
      }
    }
  ' "$config" > "$tmp"

  mv "$tmp" "$config"
}

install_codex_agents() {
  local agents="$HOME/.codex/AGENTS.md"
  local rtk="$HOME/.codex/RTK.md"
  local tmp

  mkdir -p "$HOME/.codex"
  ln -sfn "$DOTFILES/codex/RTK.md" "$rtk"

  tmp="$(mktemp)"
  sed "s#__CODEX_RTK_PATH__#$rtk#g" "$DOTFILES/codex/AGENTS.md.template" > "$tmp"
  mv "$tmp" "$agents"
}

# ── Pre-flight checks ─────────────────────────────────────────────────────────
# Fail fast if hard dependencies are missing before doing any work
command -v git  &>/dev/null || die "git is required but not installed"
command -v curl &>/dev/null || die "curl is required but not installed"
if [[ "$(uname)" == "Darwin" ]]; then
  command -v brew &>/dev/null || die "Homebrew is required on macOS — install from https://brew.sh"
fi

# ── Secrets file ──────────────────────────────────────────────────────────────
# Copy the example secrets file on first run. Fill in values before opening a shell.
if [[ ! -f "$DOTFILES/secrets/local.zsh" ]]; then
  cp "$DOTFILES/secrets/example.zsh" "$DOTFILES/secrets/local.zsh"
  info "created secrets/local.zsh from example — fill in values before opening a shell"
else
  info "secrets/local.zsh already exists, skipping"
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
  info "$HOME/.gitconfig.local already exists, skipping"
fi

# ── Homebrew packages ─────────────────────────────────────────────────────────
# Install everything listed in Brewfile. brew bundle is idempotent — safe to re-run.
if command -v brew &>/dev/null; then
  info "installing brew packages..."
  brew bundle --file="$DOTFILES/Brewfile"
else
  warn "brew not found — skipping Brewfile install"
fi

# ── Codex CLI (Linux CDEs) ───────────────────────────────────────────────────
# On macOS, Codex is installed by the Homebrew cask above. On Linux CDEs, use
# npm when available and leave auth/state to Codex itself.
if [[ "$(uname)" == "Linux" ]]; then
  if command -v codex &>/dev/null; then
    info "codex already installed, skipping"
  elif command -v npm &>/dev/null; then
    info "installing Codex CLI..."
    if npm install -g @openai/codex; then
      info "Codex CLI installed"
    else
      warn "Codex CLI install failed — run manually: npm install -g @openai/codex"
    fi
  else
    warn "npm not found — install Codex manually with: npm install -g @openai/codex"
  fi
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
mkdir -p ~/.claude
ln -sfn "$DOTFILES/claude/keybindings.json" ~/.claude/keybindings.json  # Claude Code keybindings
ln -sfn "$DOTFILES/claude/settings.json"   ~/.claude/settings.json     # Claude Code settings
mkdir -p ~/.codex
install_codex_agents                                                     # Codex global guidance + RTK
ln -sfn "$DOTFILES/codex/hooks.json"       ~/.codex/hooks.json          # Codex hooks
patch_codex_config
info "Codex config defaults patched"
mkdir -p ~/.config
ln -sfn "$DOTFILES/starship/starship.toml" ~/.config/starship.toml      # starship prompt config
mkdir -p ~/.config/ghostty
ln -sfn "$DOTFILES/ghostty/config" ~/.config/ghostty/config             # ghostty terminal config

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

# ── Linux packages ────────────────────────────────────────────────────────────
# Packages that are on macOS via Homebrew (Brewfile) but need apt on Linux CDEs.
if [[ "$(uname)" == "Linux" ]] && command -v apt-get &>/dev/null; then
  info "installing Linux packages..."
  sudo apt-get install -y -q mosh
fi

# ── Starship (Linux only) ─────────────────────────────────────────────────────
# On macOS, starship is installed via Homebrew (Brewfile). On Linux, use the
# official install script. The --yes flag skips the interactive prompt.
if [[ "$(uname)" == "Linux" ]]; then
  if command -v starship &>/dev/null; then
    info "starship already installed, skipping"
  else
    info "installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
  fi
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

# ── Git tools ──────────────────────────────────────────────────────────────────
# Clone git utilities that aren't available via package managers on all platforms.
# Referenced by path in git/gitconfig so they work on macOS and Linux alike.
info "cloning git tools..."
git_dep_dest="$DOTFILES/deps/git/diff-so-fancy"
if [ -d "$git_dep_dest" ]; then
  info "  diff-so-fancy already exists, skipping"
else
  git clone --depth 1 "https://github.com/so-fancy/diff-so-fancy" "$git_dep_dest"
fi

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
  info "installing tmux plugins..."
  ~/.tmux/plugins/tpm/bin/install_plugins
else
  warn "tmux not found — skipping TPM install"
fi

# ── Editor extensions ──────────────────────────────────────────────────────────
# Install all extensions listed in vscode/extensions for installed VSCode-family editors.
install_editor_extensions code "VSCode"
install_editor_extensions cursor "Cursor"

# ── RTK (token reduction for Claude Code) ─────────────────────────────────────
# On macOS, rtk is installed via Brewfile above.
# On Linux, use the official install script → ~/.local/bin/rtk.
if [[ "$(uname)" == "Linux" ]]; then
  if command -v rtk &>/dev/null; then
    info "rtk already installed, skipping"
  else
    info "installing rtk..."
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"   # make rtk available in this session
  fi
fi

# Install the Claude Code PreToolUse hook (idempotent).
if command -v rtk &>/dev/null; then
  info "configuring rtk for Claude Code..."
  echo "n" | rtk init -g --auto-patch
else
  warn "rtk not found — skipping rtk init (Claude Code hook not installed)"
fi

# ── peon-ping (macOS only) ────────────────────────────────────────────────────
# Registers Claude Code hooks and installs sound packs. peon-ping-setup is
# non-interactive — it auto-detects installed IDEs and wires them up.
# We pass our three target packs plus the bundled "peon" pack as a baseline.
# On re-runs the setup call is skipped (config exists); pack install is idempotent.
if [[ "$(uname)" == "Darwin" ]] && command -v peon-ping-setup &>/dev/null; then
  PEON_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/peon-ping"
  PEON_CONFIG="$PEON_CONFIG_DIR/config.json"
  if [[ ! -d "$PEON_CONFIG_DIR" ]]; then
    info "setting up peon-ping..."
    peon-ping-setup --packs=peon,ocarina_of_time,dota2_invoker
  else
    info "peon-ping already configured, ensuring packs are installed..."
    peon packs install ocarina_of_time,dota2_invoker 2>/dev/null || true
  fi
  # Manage config via dotfiles — symlink replaces any generated config
  ln -sfn "$DOTFILES/claude/peon-ping/config.json" "$PEON_CONFIG"
  info "peon-ping config symlinked from dotfiles"
else
  [[ "$(uname)" == "Darwin" ]] && warn "peon-ping-setup not found — run 'brew bundle' first"
fi

# ── Terminal bell hook (Linux CDEs) ───────────────────────────────────────────
# On headless Linux CDEs there is no audio device, so peon-ping cannot run.
# Instead, emit the terminal bell character (\a) on task complete. SSH
# forwards it to the local Ghostty terminal, which plays a system notification.
if [[ "$(uname)" == "Linux" ]]; then
  info "adding terminal bell Stop hook for Claude Code..."
  python3 - <<'PYEOF'
import json, os

path = os.path.expanduser('~/.claude/settings.json')
settings = {}
if os.path.exists(path):
    with open(path) as f:
        try:
            settings = json.load(f)
        except json.JSONDecodeError:
            pass

hooks = settings.setdefault('hooks', {})
stop_hooks = hooks.setdefault('Stop', [])

bell_cmd = "printf '\\a' > /dev/tty"
already = any(
    any('> /dev/tty' in h.get('command', '') and 'printf' in h.get('command', '') for h in entry.get('hooks', []))
    for entry in stop_hooks
)
if not already:
    stop_hooks.append({'matcher': '', 'hooks': [{'type': 'command', 'command': bell_cmd}]})
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        json.dump(settings, f, indent=2)
        f.write('\n')
    print('[info] terminal bell hook added to ~/.claude/settings.json')
else:
    print('[info] terminal bell hook already present, skipping')
PYEOF
fi

# ── Work (Vanta) setup ────────────────────────────────────────────────────────
bash "$DOTFILES/work/vanta-install.sh"

info "done. open a new shell or run: exec zsh"
