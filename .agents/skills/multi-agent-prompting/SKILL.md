---
name: multi-agent-prompting
description: Use when a task benefits from multiple AI roles: routing, independent alternatives, evaluator/optimizer separation, debate, adjudication, or self-verifying output. Helps choose simulated roles versus real subagents with scoped permissions, cost, and integration rules.
origin: skill_memo.md distilled
---

# Multi-Agent Prompting

Use this skill when one answer path is likely to be narrow, biased, or under-reviewed. Multi-agent design is useful for routing, independent alternatives, critique, debate, and verification.

Use actual subagents only when the tool environment supports them and the benefit justifies the added context and cost. Otherwise, simulate the roles inside one response.

## Boundary

- Use this skill for role design, reviewer separation, independent evidence gathering, or disagreement.
- Use `prompt-thinking-patterns` when one agent can solve the issue with a better reasoning pattern.
- Use `agent-harness-design` when roles need persistent loops, tools, memory, or guardrails.
- Use `ai-automation-ops` when subagent use should become a standing repo or team workflow.

## Patterns

- **Router**: Classify the request, choose the right expert workflow, then execute with that workflow.
- **Parallel perspectives**: Generate several independent approaches, compare them, and choose a final answer.
- **Evaluator-optimizer**: Separate the creator from the critic. Critique against a rubric, then revise.
- **Debate and adjudication**: Use opposing views for ambiguous strategy, product, policy, or architecture decisions.
- **Self-verifying output**: Review a draft from stakeholder, competitor, user, or maintainer perspectives before finalizing.

## Decision Rules

- Use one agent when the task is straightforward or mostly mechanical.
- Use simulated roles when you need diversity of thought but no external tools.
- Use real subagents when evidence gathering, review, or implementation can run independently.
- Keep each agent specialized. One role should have one job.
- Limit tool access to what each role needs.
- Prefer a small number of strong perspectives over many shallow voices.

## Workflow

1. State the decision or artifact being improved.
2. Choose the minimum roles needed: router, creator, reviewer, opponent, adjudicator, or domain expert.
3. Give all roles the same core context and rules.
4. Put role-specific tasks at the end of each role instruction.
5. Ask each role for concise findings, assumptions, and confidence.
6. Have a final integrator resolve conflicts and produce the actual deliverable.

## Role Contract

Each role should have:

- A single responsibility.
- Shared context and non-negotiable constraints.
- A narrow output shape.
- Explicit tool permissions if real subagents are used.
- A handoff rule for the final integrator.

## Quality Bar

- Roles must disagree productively or inspect different failure modes.
- The final answer must not be a transcript of the debate.
- The integrator must explain what was adopted, rejected, or left uncertain.
- For code work, findings should point to files, tests, or concrete behavior.

## Avoid

- Role theater where every role says the same thing.
- Giving every subagent full tool permissions by default.
- Running parallel agents before the problem is scoped.
- Treating majority vote as truth when evidence quality differs.
