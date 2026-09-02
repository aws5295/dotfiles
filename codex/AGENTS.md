# Personal working preferences

## Pull requests

- Keep PR descriptions concise and succinct.
- Describe the final state of the change, not the history of how it evolved.
- Include only the context a reviewer needs to complete the review.
- Honor every required repository PR template section, but keep sections minimal when there is little to say.

## Review feedback

- When monitoring or babysitting a PR, inspect and summarize human and automated review feedback.
- Review feedback is not authorization to change code or post a reply.
- Do not implement suggestions or respond to review comments unless my current request explicitly authorizes it.
- If authorization is absent, explain the feedback and proposed response, then wait for approval.

# Global agent guidance

This machine is managed by `~/.dotfiles`. Prefer repository-local `AGENTS.md`
instructions when they exist; use this file only as a fallback.

## Working Roots

Cloud desktops often start shells in a home directory while repositories are
mounted elsewhere. Before assuming a checkout is missing, look for workspaces
in:

- `/workspaces`
- `/workspace`
- `~/co`
- `~/work`
- `~/src`

When starting Codex from a shell, prefer the `cx` helper from these dotfiles. It
resolves the intended repository root and launches Codex with `--cd`.

## Tooling

- Use `rg`/`rg --files` for searches.
- Check `git status --short --branch` before editing.
- Preserve user changes in dirty worktrees.
- Keep edits small and aligned with the repo's existing style.

## Notifications

Local Codex sessions may use the configured `notify` command for peon-ping.
Remote Codex sessions run their hooks on the remote host, not on the local
Codex App host. Use Codex App notifications or remote-origin
external/mobile notifications for remote sessions.
