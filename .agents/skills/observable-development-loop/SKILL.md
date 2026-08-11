---
name: observable-development-loop
description: "Use when an AI-generated result cannot be judged from source inspection alone: visual, interactive, simulated, generated, or stateful output that needs direct observation, stable reference points, deterministic checks, retained evidence, and failure promotion before handoff."
---

# Observable Development Loop

Use this skill to give substantial implementation work a repeatable feedback
loop: observe the actual output, compare it under stable conditions, verify
what can be verified mechanically, and preserve discovered failures as durable
project knowledge.

## When To Activate

- The result cannot be judged from source inspection alone.
- Visual, interactive, simulated, generated, or stateful behavior is changing.
- A similar task previously produced plausible-looking but incorrect output.
- Repeated human review is becoming the quality bottleneck.
- A large implementation needs a repeatable feedback loop before the first
  large edit.

Skip it when the diff plus an existing check (tests, `bash scripts/lint.sh`)
fully proves the result. A small shell-script edit does not need screenshots
or a contract.

## Boundary

- This skill owns agent-visible evidence: how the agent observes its own
  output and makes before/after comparison repeatable.
- Use `agent-harness-design` for the general observe/act/verify loop, tools,
  guardrails, and stop conditions of an agent harness.
- Use `eval-bottleneck-reduction` for layered grader design, rubric
  calibration, and promoting human review into scalable evals.
- Use `ai-regression-testing` for recurring AI-authored code regressions and
  concrete regression-test patterns.
- Use `ecc-task-workflow` for durable task artifacts; this skill only fills
  their observability fields.
- Use `test-driven-development` and `verification-loop` for ordinary
  build/test/lint gates; do not restate them here.

## Evaluation Layers

Keep these layers distinct, and run them in this order:

1. **Source inspection**: reading the diff. Necessary, never sufficient for
   observable behavior.
2. **Runtime/artifact observation**: inspecting what the change actually
   produces: a running UI, CLI output, a generated file, a simulation trace.
3. **Deterministic verification**: properties checked mechanically with a
   stable pass/fail.
4. **Model/rubric evaluation**: describable but subjective properties judged
   against a written rubric.
5. **Human judgment**: taste, product, and risk decisions that stay with the
   user.

Do not report a later layer as satisfied on the strength of an earlier one.
"The code looks correct" is layer 1 evidence only.

## Observability Contract

Before or during substantial implementation, answer this shape. Keep it
proportional: a few honest lines beat a ceremonial form, and any section may
be `none` with a one-line reason.

```markdown
## Observability Contract

### Target
What output, state, behavior, or quality is being changed?

### Observation Method
How will the agent inspect the actual result rather than only the source?
Examples: fixed screenshots or camera positions, CLI output capture,
generated artifact inspection, browser runtime inspection, simulation
traces, structured logs, raycasts or reachability checks, golden inputs
and outputs.

### Stable Reference Points
Which fixtures, coordinates, scenarios, seeds, inputs, viewport sizes, or
snapshots make before/after comparison repeatable?

### Deterministic Checks
Which properties can be checked without subjective judgment?

### Rubric Checks
Which describable but subjective properties need a rubric or model-assisted
review?

### Human-Owned Judgment
Which decisions must remain with the user?

### Evidence
What commands, screenshots, reports, artifacts, or measurements must be
retained or summarized at handoff?

### Regression Promotion
If the result is rejected or a failure is discovered, what reusable test,
eval, invariant, fixture, or project rule should be added?
```

When an ECC task folder exists, put the contract in the task `implement.md`
and record the produced evidence in `check.md`.

## Loop

1. Inspect the actual runtime or generated artifact, not only the source.
2. Capture a baseline observation before changing behavior, when feasible.
3. Implement the smallest useful slice.
4. Re-run the same observation under the same reference points.
5. Run deterministic checks before model or human judgment.
6. Report evidence: commands, outputs, artifacts, measurements. Never only
   "looks correct".
7. Promote discovered failures into a regression check, a task rule, or a
   `.agents/ecc-workflow/spec/` entry.
8. Stop and escalate when the remaining decision is fundamentally subjective
   or human-owned.

## Examples

### Visual/interactive task

Adding a dark-mode settings panel to a web UI:

- Target: rendered panel layout and colors in both themes.
- Observation: load the same route in the browser runtime; capture it at a
  fixed 1280x800 viewport in light and dark mode.
- Stable reference points: fixed route, viewport size, and seeded demo data.
- Deterministic: no console errors; required elements present in the DOM;
  text contrast ratio meets the threshold.
- Rubric: spacing and hierarchy consistent with existing panels.
- Human-owned: whether the visual style fits the product's taste.
- Evidence: two screenshots plus a console log summary.
- Regression promotion: if dark mode regresses, add a check asserting the
  panel's computed colors under `prefers-color-scheme: dark`.

### CLI / generated-artifact task

Adding a mount check to `scripts/wsl-doctor.sh`:

- Target: the diagnostic report printed by the script.
- Observation: run the script and capture stdout before and after the change.
- Stable reference points: same host state; the captured baseline output for
  the unchanged sections.
- Deterministic: exit code, `bash scripts/lint.sh`, and the new section
  header appearing exactly once in the output.
- Rubric: none.
- Human-owned: whether the report ordering is helpful.
- Evidence: the before/after output capture in the task `check.md` or final
  summary.
- Regression promotion: if the check misfires, record the failing condition
  as a durable rule or keep the reproducing input documented in the task
  folder.

## Avoid

- Duplicating generic TDD or verification-loop guidance.
- Prescribing a specific browser, screenshot, or testing framework.
- Assuming every project is visual.
- Installing external harnesses or dependencies to obtain observability.
- Requiring heavyweight artifacts or contracts for small edits.
- Replacing human taste or product judgment with an unreliable model-only
  score.
