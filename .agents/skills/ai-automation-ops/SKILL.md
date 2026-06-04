---
name: ai-automation-ops
description: Use when operationalizing Claude Code or Codex workflows into repo or team practice: plan gates, AGENTS.md or CLAUDE.md rules, scoped prompts, subagent permissions, MCP minimalism, repeatable Skill packaging, review gates, and eval-minded prompt improvement.
origin: skill_memo.md distilled
---

# AI Automation Ops

Use this skill when turning AI-assisted work from ad hoc prompting into a repeatable operating system for a repo, team, or personal workflow.

## Boundary

- Use this skill for repo-level operating practice, tool configuration, MCP selection, plan gates, review gates, and Skill packaging.
- Use `agent-harness-design` when designing a single tool-using agent workflow.
- Use `context-architecture` when deciding where durable context should live.
- Use `prompt-thinking-patterns` or `outcome-first-prompting` when the task is only prompt improvement.

## Operating Principles

- Plan before broad edits or automation.
- Put durable rules in project instruction files.
- Keep per-turn prompts focused on the current task.
- Scope tools and permissions to the job.
- Keep MCP servers and connectors minimal.
- Promote repeated workflows into Skills.
- Measure prompt quality with examples, tests, or rubrics.

## Codex And Claude Code Workflow

1. **Plan gate**: For nontrivial work, identify files, risks, verification, and the order of operations before acting.
2. **Durable rules**: Put stable preferences, security rules, and repo conventions in `AGENTS.md` for Codex or `CLAUDE.md` for Claude Code.
3. **Task prompts**: Put only this turn’s goal, constraints, and acceptance criteria in the user prompt.
4. **Subagents**: Use specialized roles with minimal tools; account for added context and cost.
5. **MCP discipline**: Enable only servers that are used often or are necessary for the current task.
6. **Skill packaging**: If a workflow appears two or three times, make it a Skill with concise trigger metadata.
7. **Review before push**: Inspect diffs, run relevant checks, and avoid committing unrelated changes.

## MCP Selection

Use MCP or connectors when they unlock external data, actions, or memory that the model cannot safely infer. Disable or avoid them when they only add context noise.

Useful categories:

- Search and research.
- Browser or Playwright interaction.
- GitHub PR and issue operations.
- Memory for durable user or project facts.
- Domain data sources used daily.

## Eval-Minded Prompt Improvement

- Run the same prompt across representative examples.
- Compare output variance.
- Write a short rubric for what good means.
- Change one prompt variable at a time.
- Keep the prompt version that performs best against the rubric, not the one that sounds best.

## Output Contract

For an ops request, produce:

- What belongs in project instructions.
- What belongs in the per-turn prompt.
- Which tools, MCPs, or connectors are needed.
- Whether a plan gate or approval gate is required.
- What verification must run before commit or push.
- Whether the workflow should become a Skill.

## Avoid

- Loading every rule, MCP, and agent into every session.
- Using Plan Mode as theater without concrete file and verification details.
- Letting subagents inherit broad permissions by accident.
- Copying prompt snippets forever instead of packaging stable workflows.
- Treating manual taste as a substitute for test cases or rubrics.
