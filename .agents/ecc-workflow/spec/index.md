# ECC Workflow Specs

These specs are stable context for agents working in this dotfiles repository.
They are intentionally lighter than a full external agent-harness installation.

## Repository Role

`MySettings` stores reproducible Mac and WSL setup files plus the local ECC /
Codex baseline. Changes should favor repeatability, idempotence, and clear
separation between shared project defaults and host-local state.

## Durable Rules

- Keep Mac-specific settings under `settings/mac/`.
- Keep WSL-specific settings under `settings/wsl/`.
- Keep shared shell/editor defaults under `settings/common/`.
- Setup scripts should be idempotent and avoid destructive deletion.
- Host credentials, notifications, and personal tokens belong in user-local
  config files, not in tracked project baselines.
- Project-local Codex defaults live in `.codex/config.toml`.
- Project-local skills live in `.agents/skills/`.
- Structured workflow files live in `.agents/ecc-workflow/`.

## When To Create Task Artifacts

Create a task folder when any of these are true:

- The work touches multiple files or workflows.
- The work may continue across sessions.
- The work changes agent behavior, skills, MCP configuration, setup scripts, or
  other durable automation.
- The acceptance criteria are not obvious from the user prompt.

Skip task artifacts for tiny answers, one-line edits, or direct command output.
