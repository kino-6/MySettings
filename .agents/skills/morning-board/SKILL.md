---
name: morning-board
description: One page on what AI agents did overnight across every repository under a root directory - running Claude Code sessions, commits after a boundary time, queue rows that became [x], and rows waiting on a human ([~]), blocked ([!]) or in progress ([-]). Read-only, standard library only. Use when the user asks what happened overnight, which repos need their judgement, or wants the "朝の 1 枚".
---

# Morning Board

Agents run at night in several repositories. In the morning the person wants one
answer per repository: is anything still running, what got done, and what is
waiting on them. This skill gives that page in one command and writes nothing.

```bash
python3 scripts/board.py                              # every repo directly under ~/work, since yesterday 18:00
python3 scripts/board.py --since 2026-10-30T22:00     # another boundary
python3 scripts/board.py --root DIR --check           # exit 1 if a shown row was misread (lines on stderr)
```

Show the Markdown it prints as is. Lead with the `判断待ち` rows: those are the
ones only the person can move. `動きなし` at the end lists repositories with a
queue and nothing to report.

## Where each part comes from

- **Rows**: the repo's `Tasks.md` / `TASKS.md`, in the markers of
  `task-queue-loop` (bullet `- [~] **T376 — 題**` or table `| [~] | V-6 | 題 |`).
  Only top-level rows; nested ones are a row's breakdown.
- **Finished**: the git diff from the last commit before `--since` to `HEAD`, over
  the queue and any `*archive*.md`. A finished row is soon moved out of the
  queue, so reading the file alone would miss it. Rows already `[x]` at the
  boundary are left out.
- **Sessions**: `claude agents --json`, the agent view built into Claude Code,
  matched to a repo by `cwd`. If `claude` is missing or answers something
  unexpected, the sessions are left out and the queues still show.
  `--agents-json FILE` reads a saved answer instead.

## Limits

- A finished row with no ID is not listed under `終わった`.
- Uncommitted edits to the queue or archive do not count as finished.
- A session whose `cwd` reaches the repo through a symlink is not matched.

## Tests

`python3 scripts/test_board.py` (unittest, temporary git repos with fixed dates,
a fake `claude` on `PATH`). The repro with the fixtures:

```bash
python3 scripts/board.py --root scripts/fixtures --since 2000-01-01 --agents-json scripts/fixtures/agents.json
```
