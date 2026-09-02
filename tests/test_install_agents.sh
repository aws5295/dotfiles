#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT

HOME="$TEST_HOME" bash "$REPO_ROOT/codex/install-agents.sh"

test -s "$TEST_HOME/.codex/AGENTS.md"
test -s "$TEST_HOME/.claude/CLAUDE.md"
grep -Fq "# Personal working preferences" "$TEST_HOME/.codex/AGENTS.md"
grep -Fq "# Personal working preferences" "$TEST_HOME/.claude/CLAUDE.md"
grep -Fq "@${TEST_HOME}/.codex/RTK.md" "$TEST_HOME/.codex/AGENTS.md"
if grep -Fq "@${TEST_HOME}/.codex/RTK.md" "$TEST_HOME/.claude/CLAUDE.md"; then
  exit 1
fi
test -L "$TEST_HOME/.codex/RTK.md"
test "$(readlink "$TEST_HOME/.codex/RTK.md")" = "$REPO_ROOT/codex/RTK.md"

echo "PASS: shared personal agent instructions installed for Codex and Claude"
