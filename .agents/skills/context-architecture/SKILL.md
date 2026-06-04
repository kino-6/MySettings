---
name: context-architecture
description: Use when a prompt, agent, or long-running task needs better context structure: stable prefixes, bookended constraints, just-in-time reference loading, intent encoding, specification layers, anchor documents, session continuity, differential edits, or cache-aware layout.
origin: skill_memo.md distilled
---

# Context Architecture

Use this skill when the issue is not the wording of a prompt, but the placement, persistence, and retrieval of context. Good context architecture makes long tasks more reliable and cheaper to continue.

## Boundary

- Use this skill for context placement, retrieval strategy, durable rules, and long-session continuity.
- Use `outcome-first-prompting` when the main problem is the final output schema.
- Use `agent-harness-design` when the context is part of a tool-using autonomous loop.
- Use `ai-automation-ops` when durable context should be installed as repo instructions or MCP configuration.

## Core Model

Treat context as layered environment:

- **Prompt**: the immediate task.
- **Context**: relevant facts, examples, docs, and constraints.
- **Intent**: priorities, tradeoffs, and default decisions.
- **Specification**: stable rules and acceptance criteria that should outlive one prompt.

## Placement Rules

- Put durable rules and stable context near the beginning.
- Repeat critical constraints at the end for long prompts.
- Keep volatile task details near the end.
- Do not bury important constraints in the middle of a long paste.
- Keep common prefixes stable across related prompts or subagents.

## Retrieval Rules

- Start large-document work with a table of contents, summaries, and search terms.
- Load only the relevant section when details are needed.
- Ask for missing source material instead of hallucinating from a title.
- Use `rg` or structured indexes before reading large files.
- Summarize and anchor long-running context before continuing in a new thread.

## Patterns

- **Bookend constraints**: State non-negotiables at the top and bottom of long instructions.
- **Goldilocks altitude**: Write rules at the middle level: principles, decision frames, and controlled freedom.
- **Just-in-time context**: Load only the reference needed for the next decision.
- **Intent encoding**: Capture priorities, hard no-go rules, and default decisions.
- **Specification layer**: Promote repeated requirements into structured specs or project instructions.
- **Stable prefix first**: Keep repeated background identical so follow-up work can reuse context efficiently.
- **Anchor document**: Provide a reference once, then refer back to it rather than reposting it.
- **Differential edit**: Request only the changed part when revising.

## Workflow

1. Separate stable from volatile information.
2. Move stable rules into project files, specs, or Skill bodies.
3. Keep per-turn prompts focused on the current task.
4. For long docs, build an index before deep reading.
5. For follow-ups, state the delta instead of restating everything.
6. Compact context when the session becomes long or the active goal changes.

## Context Packet

For large or repeated work, shape context as:

```markdown
Stable rules:

Intent and tradeoffs:

Reference index:

Loaded references:

Current task:

Delta from previous turn:
```

## Avoid

- Pasting every reference "just in case."
- Repeating large documents in every turn.
- Writing system-level rules as ad hoc task prompts.
- Making rules so abstract they cannot guide decisions.
- Making rules so specific they break on normal variation.
