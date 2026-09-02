#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${EFS_MOUNT_POINT:-}" ]]; then
  echo "[skip] EFS_MOUNT_POINT is not set"
  exit 0
fi

EFS_DIR="${EFS_MOUNT_POINT%/}"
if [[ ! -d "$EFS_DIR" ]]; then
  echo "[skip] EFS mount is not available at $EFS_DIR"
  exit 0
fi

link_to_efs() {
  local name="$1"
  local src="$HOME/$name"
  local dst="$EFS_DIR/$name"
  local backup

  if [[ -L "$src" && "$(readlink "$src")" == "$dst" ]]; then
    return 0
  fi

  # The first machine migrates its existing history to EFS. Never overwrite
  # an existing EFS file during migration.
  if [[ ! -e "$dst" && ! -L "$dst" && -e "$src" && ! -L "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    mv "$src" "$dst"
  fi

  # Preserve local state if EFS already has a copy. This avoids silently
  # deleting commands from a newly-created environment.
  if [[ -e "$src" || -L "$src" ]]; then
    backup="$src.pre-efs.$(date +%s)"
    mv "$src" "$backup"
    echo "[info] preserved local $name at $backup"
  fi

  mkdir -p "$(dirname "$src")"
  ln -s "$dst" "$src"
}

link_to_efs ".zsh_history"
echo "[info] EFS history symlink configured"
