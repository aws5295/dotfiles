#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

HOME="$TEST_ROOT/home"
EFS_MOUNT_POINT="$TEST_ROOT/efs"
mkdir -p "$HOME" "$EFS_MOUNT_POINT"
printf ': 1780000000:0;echo local\n' > "$HOME/.zsh_history"

HOME="$HOME" EFS_MOUNT_POINT="$EFS_MOUNT_POINT" \
  bash "$REPO_ROOT/post-start-install.sh"

test -L "$HOME/.zsh_history"
test "$(readlink "$HOME/.zsh_history")" = "$EFS_MOUNT_POINT/.zsh_history"
grep -Fq "echo local" "$EFS_MOUNT_POINT/.zsh_history"

printf ': 1780000001:0;echo shared\n' >> "$EFS_MOUNT_POINT/.zsh_history"
HOME="$HOME" EFS_MOUNT_POINT="$EFS_MOUNT_POINT" \
  bash "$REPO_ROOT/post-start-install.sh"
test "$(readlink "$HOME/.zsh_history")" = "$EFS_MOUNT_POINT/.zsh_history"
grep -Fq "echo shared" "$EFS_MOUNT_POINT/.zsh_history"

SECOND_HOME="$TEST_ROOT/second-home"
mkdir -p "$SECOND_HOME"
printf ': 1780000002:0;echo local-only\n' > "$SECOND_HOME/.zsh_history"
HOME="$SECOND_HOME" EFS_MOUNT_POINT="$EFS_MOUNT_POINT" \
  bash "$REPO_ROOT/post-start-install.sh"

test -L "$SECOND_HOME/.zsh_history"
test "$(readlink "$SECOND_HOME/.zsh_history")" = "$EFS_MOUNT_POINT/.zsh_history"
test "$(find "$SECOND_HOME" -maxdepth 1 -name '.zsh_history.pre-efs.*' | wc -l | tr -d ' ')" = 1
grep -Fq "echo local-only" "$SECOND_HOME"/.zsh_history.pre-efs.*

echo "PASS: EFS history link is migratable and idempotent"
