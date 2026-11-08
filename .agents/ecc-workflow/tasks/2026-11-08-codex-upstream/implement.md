# Implementation Notes

## Relevant Context

- Installed and latest release: Codex CLI 0.167.0.
- `persistent_instructions` fails strict parsing.
- `[profiles.<name>]` has been ignored since Codex 0.134.0.
- Native lifecycle hooks are stable, but command hook failures are not a
  security boundary.

## Plan

1. Add a failing Stop-hook compatibility test.
2. Make the existing report check emit the runtime-specific Stop response.
3. Migrate config/profile files and add strict parsing checks.
4. Correct the conflicting documentation.
5. Deploy the scoped user files and exercise the installed CLI.
6. Run the row gate, repository checks, and an independent gate audit.

## Observability Contract

- Target: active Codex config, profile loading, and Stop-hook continuation.
- Observation method: strict app-server config parse, deterministic hook input,
  hook discovery/runtime output, and active-file inspection.
- Stable reference points: Codex 0.167.0 schemas and official documentation.
- Deterministic checks: `scripts/check-codex-config.sh` and
  `test_report_check.py`.

## Verification Plan

- Prove the minimum check is red before implementation.
- Validate base config and both profile files in isolated `CODEX_HOME` trees.
- Feed English, Japanese, malformed, and already-retried inputs to the hook.
- Confirm the installed user files match the tracked copies.
