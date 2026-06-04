---
name: prompt-thinking-patterns
description: Use when a prompt or workflow needs a better reasoning pattern: verification, self-refine, branch exploration, skeleton-first drafting, neutral reframing, pre-mortems, counter-hypotheses, or confidence labels. Prefer outcome-first-prompting for output schemas and context-architecture for large-context layout.
origin: skill_memo.md distilled
---

# Prompt Thinking Patterns

Use this skill when a task needs better thinking structure, not merely a more polished instruction. The goal is to choose one reasoning pattern that fits the failure mode and turn it into a concise, task-specific prompt or workflow.

Do not reproduce source prompt templates verbatim. Extract the pattern, adapt it, and keep only the operational steps.

## Boundary

- Use this skill for reasoning quality, uncertainty, critique, ideation, and long-form thinking flow.
- Use `outcome-first-prompting` when the main need is a stable output contract.
- Use `multi-agent-prompting` when the solution requires multiple independent roles or subagents.
- Use `context-architecture` when the main failure is context placement, retrieval, or session continuity.
- Use `agent-harness-design` when the workflow needs tools, loops, memory, or guardrails.

## Decision Matrix

- **Verification loop**: Use for factual, research, legal, medical, financial, or source-sensitive work. Ask for a draft, identify risky claims, verify them against evidence, then revise.
- **Self-refine**: Use for writing, product copy, strategy memos, and design docs. Produce a draft, critique it with a named rubric, then rewrite.
- **Branch exploration**: Use when multiple solutions may be valid. Generate several approaches, compare tradeoffs, choose one, then deepen only the best branch.
- **Skeleton-first drafting**: Use for long documents, presentations, articles, specs, or proposals. Create the outline first, validate it, then fill sections.
- **Meta-prompting**: Use when a reusable prompt is becoming an asset. Generate variants, explain what each improves, select one, and save the result.
- **Neutral reframing**: Use when the user wording is leading, emotional, or likely to invite agreement bias. Rephrase as a neutral question before answering.
- **Counter-hypothesis**: Use when the first answer may be obvious or conventional. Explore the opposite answer before finalizing.
- **Pre-mortem**: Use before long or high-risk tasks. Name likely failure modes, mitigation steps, then execute.
- **Calibrated confidence**: Use when uncertainty matters. Label claims by confidence, separate facts from inferences, and state what would change the conclusion.

## Workflow

1. Identify the task risk: factual risk, quality risk, strategy risk, creativity risk, or execution risk.
2. Pick one or two patterns only. Combining too many patterns makes prompts heavy and brittle.
3. Define the visible output: final answer, critique table, decision memo, outline, or improved prompt.
4. Ask for concise reasoning artifacts, not hidden chain-of-thought. Prefer summaries, assumptions, checks, tradeoffs, and confidence labels.
5. For unstable facts, use current sources or ask to verify before finalizing.
6. Save useful prompt improvements into a project Skill, command, or playbook instead of leaving them in chat.

## Output Contract

Return one of these, depending on the request:

- A revised prompt with the selected pattern embedded.
- A short workflow the agent should follow.
- A critique of an existing prompt with specific changes.
- A reusable rule suitable for a Skill, command, or project instruction.

## Quality Bar

- The pattern must reduce a real failure mode.
- The final prompt should state the goal, constraints, evaluation criteria, and output shape.
- The response should distinguish evidence, inference, and speculation.
- The workflow should end with a usable final artifact, not only analysis.

## Avoid

- Adding "think step by step" mechanically.
- Using expert personas for factual accuracy when a rubric, source check, or schema would be better.
- Asking for many roles or many rounds when a single checklist would solve the problem.
- Treating confidence scores as proof; they are triage signals.
