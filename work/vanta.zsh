# -*- mode: sh -*-
# Vanta-specific aliases and functions

# ── Gitpod (cloud desktop) ────────────────────────────────────────────────────
# Commands that should only run on Vanta's Gitpod cloud desktop environment
if [[ -n "$GITPOD_API_URL" ]]; then
  # Load Vanta secrets injected by the Gitpod environment
  [[ -f /etc/profile.d/ona-secrets.sh ]] && source /etc/profile.d/ona-secrets.sh
  # Show "CDE" in the starship prompt context segment instead of the Gitpod hostname
  export DOT_CONTEXT="CDE"
fi

# ── cde: cloud dev environment manager ───────────────────────────────────────
# Usage:
#   cde                  — list all environments
#   cde <name>           — connect via SSH (starts/creates if needed)
#   cde <name> --mosh    — connect via mosh (roams through sleep/wake, UDP)
#
# SSH keepalives: SSH will detect a dead connection within ~90s of a drop
# (e.g. after sleep) and exit cleanly. The terminal is reset automatically
# on exit so you never need to run `reset` after a disconnection.
_cde_ssh_connect() {
  local env_id="$1" name="$2"
  # ServerAliveInterval/CountMax: send keepalives every 30s; give up after 3
  # missed replies (~90s), so SSH exits cleanly rather than hanging after sleep.
  ona environment ssh "$env_id" -- \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -t "TERM=xterm-256color zsh -i -c 't $name --layout web'"
  # Reset terminal state after disconnect — fixes garbled output after sleep/wake
  stty sane 2>/dev/null
  tput cnorm 2>/dev/null  # restore cursor visibility
  printf '\033[?1049l'    # exit alternate screen (if an app left it active)
  printf '\033[0m'        # reset text attributes
}

cde() {
  if [[ $# -eq 0 ]]; then
    echo "Environments:"
    ona environment list
    echo ""
    echo "Usage: cde <name>  # connect to or create an environment"
    return 0
  fi

  if [[ $# -ne 1 ]]; then
    echo "Usage: cde <name>  # connect to or create an environment"
    return 1
  fi

  local name="$1"

  # Fetch all environments and look for one matching the given name
  local env_id
  env_id=$(ona environment list -o json 2>/dev/null | jq -r ".[] | select(.metadata.name == \"$name\") | .id" 2>/dev/null | head -n1)

  if [[ -n "$env_id" ]]; then
    echo "Connecting to '$name'..."
    _cde_ssh_connect "$env_id" "$name"
  else
    # No environment with that name — create a new one from the ONA_PROJECT_ID project.
    # IDs are sourced from secrets/local.zsh (gitignored).
    echo "No environment named '$name' found. Creating new environment..."
    if [[ -z "$ONA_PROJECT_ID" || -z "$ONA_OHIO_CLASS_ID" ]]; then
      echo "Error: ONA_PROJECT_ID and ONA_OHIO_CLASS_ID must be set in secrets/local.zsh"
      return 1
    fi
    if ! ona environment create "$ONA_PROJECT_ID" --name "$name" --class-id "$ONA_OHIO_CLASS_ID"; then
      echo "Error: 'ona environment create' failed"
      return 1
    fi

    # Look up the new environment by name to get its ID
    env_id=$(ona environment list -o json 2>/dev/null | jq -r ".[] | select(.metadata.name == \"$name\") | .id")

    if [[ -z "$env_id" || "$env_id" == "null" ]]; then
      echo "Error: failed to find newly created environment '$name'"
      return 1
    fi

    echo "Connecting..."
    _cde_ssh_connect "$env_id" "$name"
  fi
}
# Note: mosh was investigated but ONA's VPC firewalls UDP 60000-61000, which
# mosh requires. If ONA opens those ports in the future, the shim approach
# works — the missing piece was --experimental-remote-ip=local + --bind-server=any
# with the real CDE IP fetched via a preliminary SSH call.
