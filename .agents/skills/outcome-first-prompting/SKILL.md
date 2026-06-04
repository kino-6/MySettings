---
name: outcome-first-prompting
description: Use when a prompt needs stable, repeatable output: artifact type, schema, format, acceptance criteria, examples, constraints, or prefilled opening. Prefer prompt-thinking-patterns for reasoning quality and context-architecture for large references or durable context.
origin: skill_memo.md distilled
---

# Outcome-First Prompting

Use this skill when the main problem is output drift: vague structure, inconsistent tone, missing fields, unwanted preambles, or answers that do not match the user’s target artifact.

Outcome-first prompting starts with the finished artifact and works backward.

## Boundary

- Use this skill for output shape, completion criteria, formatting stability, and constraint clarity.
- Use `prompt-thinking-patterns` when the problem is reasoning, uncertainty, or critique depth.
- Use `context-architecture` when the prompt contains large references, durable rules, or session state.
- Use `ai-automation-ops` when the output spec should become a repo workflow, Skill, or team convention.

## Build The Spec

1. **Name the artifact**: article, PR description, issue, rubric, table, JSON object, email, slide outline, test plan, etc.
2. **Define required sections or fields**: include order, length, required keys, and whether empty values are allowed.
3. **State success criteria**: what must be true for the output to be accepted.
4. **Add constraints**: prohibited phrases, tone boundaries, citation rules, style limits, formatting rules, or domain restrictions.
5. **Separate context from output shape**: use explicit labels or tags for goal, context, constraints, examples, and output format.
6. **Use examples sparingly**: one good example usually beats a long pile of mixed examples.
7. **Decide whether a role helps**: use roles for taste, audience, safety, or review perspective; avoid role dressing for factual or coding accuracy.

## Useful Techniques

- **Output-first schema**: Provide the exact structure before asking for content.
- **Response prefill**: Give the first sentence or first key only when you need to suppress preambles or lock the format.
- **Negative constraints**: List concrete things to avoid. Make violations easy to detect.
- **Structured tags**: Separate goal, context, constraints, examples, and output format when the prompt contains multiple kinds of information.
- **Persona stack**: Combine creator, reviewer, and audience perspectives only when the output benefits from taste or reception checks.

## Prompt Skeleton

Use this shape when designing a prompt:

```markdown
Goal:

Context:

Output format:

Acceptance criteria:

Constraints:

Examples or references:

Task:
```

## Output Contract

When applying this skill, produce a prompt or spec with:

- Artifact name.
- Required sections or fields.
- Acceptance criteria.
- Constraints and forbidden outputs.
- Context or references.
- The exact task to perform.

## Review Checklist

- Can another agent produce the same shape from the prompt?
- Are constraints testable rather than vibes-based?
- Is the expected output visible before the task details?
- Are "do not" rules concrete enough to catch violations?
- Is the prompt shorter than the artifact it tries to control?

## Avoid

- Asking for "a good answer" without defining good.
- Mixing background, requirements, examples, and format in one paragraph.
- Overusing personas when schemas, rubrics, or examples would be more reliable.
- Making the first line decorative instead of useful.
