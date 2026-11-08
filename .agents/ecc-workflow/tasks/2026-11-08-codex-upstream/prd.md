# PRD

## Goal

Bring the tracked and active Codex configuration in line with Codex CLI 0.167.0,
add an offline strict-config gate, and adopt the existing Japanese final-response
check as a native Codex Stop hook after proving its behavior.

## Scope

In scope:

- Remove or migrate ignored configuration.
- Add user profile files in the location used by current Codex.
- Add strict configuration checks to the repository gate.
- Preserve Claude Code hook behavior while adding Codex output.
- Correct Codex documentation that disagrees with active configuration.
- Deploy and verify the scoped user-level Codex files on this machine.

Out of scope:

- Importing Codex source, SDKs, or build tooling.
- Enabling unused MCP servers or experimental features.
- Treating hooks as a security boundary.

## Acceptance Criteria

- Tracked Codex config and profiles pass Codex strict parsing.
- The Stop hook detects a long English final answer and requests one retry.
- The retry guard prevents a loop.
- Claude Code output remains compatible.
- The normal repository check includes the Codex config check.
- Active user configuration no longer contains the rejected key.

## Risks

- Hook output formats differ between Claude Code and Codex.
- User hook trust can prevent an otherwise valid hook from executing.
- Profile files are user-level layers, not project-local profile tables.
