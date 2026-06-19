---
name: agent-self-review
description: Lightweight one-pass self review for agent-produced work. Use after Codex creates or changes code, documentation, configuration, plans, or other artifacts to check the result once, make minimal in-scope fixes when needed, and report verification, unresolved risk, or unreviewed areas without turning the review into a strict gate.
---

# Agent Self Review

## Overview

Use this skill to add a short, practical self-review pass to agent work. The goal is not to prove the work perfect; it is to catch obvious misses, repair small issues, and make the remaining risk visible.

## Principles

- Run at most one self-review pass for the current deliverable unless the user explicitly asks for deeper iteration.
- Keep fixes minimal and within the user's requested scope.
- Do not convert the review into an `ok=true` / `ok=false` gate.
- Do not require subagents, external reviewers, or `/review`; use them only when they are already appropriate for the task and allowed by the active environment.
- If a problem needs a broad redesign, new requirements, or a separate workstream, report it as remaining risk instead of expanding the task silently.
- Treat critical unverified paths honestly. If the change affects security, data loss, external side effects, public APIs, infrastructure, or credentials, call out missing verification clearly.

## Self-Review Pass

Check the finished work once from a reviewer posture:

1. Re-read the user's latest request and compare it with the artifact or diff.
2. Check whether the change stayed within scope and followed nearby project patterns.
3. Look for correctness, compatibility, security, data integrity, error handling, and testing gaps before style nits.
4. Inspect the changed files and the most relevant surrounding context. Do not chase unrelated cleanup.
5. Apply small fixes immediately when they are clearly correct and in scope.
6. Run the most relevant verification available for the project and change size, or record why verification was not run.

## Review Depth

Choose the lightest useful depth:

- **light**: Small, low-risk text or code changes. Review the diff and run targeted validation when available.
- **standard**: Behavior changes, multiple files, or config changes. Check callers, tests, and relevant configuration.
- **deep**: Security boundaries, destructive data actions, external side effects, public APIs, credentials, infrastructure, or broad refactors. Consider independent review only if the user and environment allow it; otherwise report the residual risk explicitly.

## Reporting

Keep final reporting brief. Include only the parts that matter:

- What changed
- What the self-review checked
- Any issue found and fixed during the pass
- Verification run
- Remaining risk or skipped verification
