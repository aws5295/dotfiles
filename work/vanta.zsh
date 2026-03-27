# -*- mode: sh -*-
# Vanta-specific aliases and functions

# ── Gitpod (cloud desktop) ────────────────────────────────────────────────────
# Commands that should only run on Vanta's Gitpod cloud desktop environment
if [[ -n "$GITPOD_API_URL" ]]; then
  # Load Vanta secrets injected by the Gitpod environment
  [[ -f /etc/profile.d/ona-secrets.sh ]] && source /etc/profile.d/ona-secrets.sh
fi

# ── cde: cloud dev environment manager ───────────────────────────────────────
# Usage:
#   cde           — list all environments
#   cde <name>    — connect to the named environment (starts it if stopped,
#                   creates a new ona environment if not found)
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
  local env_id env_phase
  env_id=$(ona environment list -o json 2>/dev/null | jq -r ".[] | select(.metadata.name == \"$name\") | .id" 2>/dev/null | head -n1)

  if [[ -n "$env_id" ]]; then
    # --start will start the environment if it isn't running and wait until it's ready
    echo "Connecting to '$name'..."
    ona environment ssh "$env_id" -- -t "TERM=xterm-256color zsh -i -c 't $name --layout web'"

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
    ona environment ssh "$env_id" -- -t "TERM=xterm-256color zsh -i -c 't $name --layout web'"
  fi
}
