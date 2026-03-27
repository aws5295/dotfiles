# -*- mode: sh -*-
# Platform-specific environment setup.
# Targets: M1 Mac (Darwin) and Linux CDEs (e.g. Gitpod).

case "$(uname)" in
  Darwin)
    # Homebrew on Apple Silicon lives at /opt/homebrew (not /usr/local as on Intel).
    # `brew shellenv` sets PATH, MANPATH, and INFOPATH for the current session.
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Prefer GNU tools (installed via brew) over the BSD versions that ship with macOS.
    # e.g. gnu-sed gives you a standard `sed`, findutils gives standard `find`, etc.
    for p in /opt/homebrew/opt/*/libexec/gnubin; do
      [[ -d "$p" ]] && PATH="$p:$PATH"
    done
    export PATH

    # Add Rust/Cargo binaries to PATH if Rust is installed
    [[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"
    ;;

  Linux)
    # Add Rust/Cargo binaries to PATH if Rust is installed
    [[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"
    ;;
esac

# ── Prompt context ────────────────────────────────────────────────────────────
# DOT_CONTEXT drives the user@<name> segment of the starship prompt.
# Fall back to the short hostname if not already set (e.g. via secrets/local.zsh).
# work/vanta.zsh overrides this to "CDE" when running inside a Gitpod environment.
export DOT_CONTEXT="${DOT_CONTEXT:-$(hostname -s)}"
