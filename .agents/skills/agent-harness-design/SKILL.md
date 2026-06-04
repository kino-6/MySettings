---
name: agent-harness-design
description: Use when designing or improving a tool-using AI agent harness: execution loops, guardrails, tool boundaries, environment assumptions, context compaction, playbook memory, stop conditions, self-improving instructions, and harness optimization.
origin: skill_memo.md distilled
---

# Agent Harness Design

Use this skill when the user needs an AI workflow that does more than answer once. A harness defines how the model plans, acts, checks results, uses tools, preserves memory, and stops for human review.

## Boundary

- Use this skill for autonomous or semi-autonomous workflows with tools, loops, memory, guardrails, or stop conditions.
- Use `multi-agent-prompting` when the main design question is role decomposition.
- Use `context-architecture` when the main issue is prompt/reference layout.
- Use `ai-automation-ops` when the harness must be installed into Codex, Claude Code, MCP, or repo conventions.

## Harness Components

- **Model**: the reasoning engine.
- **Instructions**: goals, principles, constraints, and review standards.
- **Tools**: APIs, filesystem, browser, MCP servers, code execution, or external services.
- **Environment**: repo, runtime, permissions, data sources, and deployment context.
- **Loop**: observe, decide, act, inspect result, adjust, and continue.
- **Guardrails**: approval gates, destructive-action limits, privacy rules, and uncertainty handling.

## Execution Loop

Use this loop for long or risky tasks:

1. Observe the current state and constraints.
2. Decide the next smallest useful action.
3. Critique the action for likely failure or risk.
4. Act with the appropriate tool or edit.
5. Verify the result.
6. Update the plan, memory, or instructions if the task will recur.

The loop should be visible enough for review, but concise. Do not dump private chain-of-thought; provide actionable state, decisions, and checks.

## Memory And Improvement

- **Context compaction**: Periodically summarize confirmed facts, open tasks, decisions, and next actions.
- **Playbook memory**: After repeated work, extract reusable rules into a Skill, command, or project instruction.
- **Self-modification**: When a workflow fails, revise the instructions that caused the failure.
- **Harness optimization**: Review tool use, prompts, guardrails, and evaluation criteria as a system.

## Guardrail Checklist

- What actions require human approval?
- What data must not be exposed or persisted?
- What tools are necessary, and which are intentionally unavailable?
- What does the agent do when sources conflict?
- How does it detect that it is stuck?
- What tests or checks prove the task is done?

## Harness Spec

When asked to design a harness, return a concise spec:

```markdown
Goal:
Environment:
Tools:
Loop:
Guardrails:
Memory:
Human approval points:
Verification:
Stop conditions:
```

## Avoid

- Treating a chat prompt as a full agent.
- Giving tools without stating when to use them.
- Adding memory without a rule for pruning or correction.
- Optimizing for autonomy before defining stop conditions.
- Letting self-improvement overwrite user intent or project policy.
