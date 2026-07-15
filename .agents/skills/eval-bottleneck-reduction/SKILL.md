---
name: eval-bottleneck-reduction
description: Design evaluation systems that reduce human review bottlenecks in AI-driven work. Use when users discuss eval bottlenecks, human-in-the-loop review, LLM-as-judge, AI output quality gates, rubric design, active review triage, golden task sets, or turning subjective human judgment into scalable eval and regression workflows.
---

# Eval Bottleneck Reduction

Use this skill to turn slow human evaluation into a layered, improving evaluation loop. The goal is not to remove humans; it is to make human review scarce, high-signal, and continuously converted into reusable evals.

## Core Model

Split evaluation into three layers:

1. **Deterministic gates**: tests, typecheck, lint, schema validation, snapshots, contracts, forbidden patterns, cost/latency budgets.
2. **Model graders**: LLM-as-judge rubrics for subjective but describable quality, such as clarity, completeness, style fit, spec adherence, or reasoning quality.
3. **Human graders**: final judgment for ambiguous, high-risk, strategic, legal, security, brand, or product-taste decisions.

Prefer deterministic gates whenever possible. Use model graders to narrow the queue. Use humans for adjudication and calibration.

## Workflow

### 1. Capture The Human Standard

Ask what a good result means in observable terms:

- What would make this output unacceptable?
- What would a careful human reviewer check first?
- Which failures have happened before?
- Which dimensions are subjective but still explainable?
- Which decisions must stay human-owned?

Convert answers into a rubric with pass/fail checks first, scores only when pass/fail is too brittle.

### 2. Build A Golden Task Set

Create 10-50 representative tasks from real work:

- common requests
- high-value workflows
- previous failures
- edge cases
- tasks where reviewers frequently disagree

For each task, store the input, expected properties, known failure modes, required sources or artifacts, and the grader type.

### 3. Route Review By Risk

Do not send everything to human review. Escalate when:

- deterministic gates fail or are absent for critical behavior
- model graders disagree
- confidence is low
- the change touches security, privacy, money, credentials, legal, or user-visible trust
- output affects brand/product positioning
- the task resembles a known failure mode
- the cost of a false positive is high

Everything else can pass with automated evidence and sampled audit.

### 4. Calibrate LLM Judges

Treat model graders as useful but biased reviewers:

- run model graders against human-scored examples
- measure where model and human judgment diverge
- tighten the rubric around repeated divergences
- require short evidence citations from the judge
- avoid release gates that depend on a flaky model-only score

Use at least two independent graders or prompt variants for high-risk subjective checks.

### 5. Promote Human Corrections Into Evals

Every time a human rejects or edits an AI output, capture:

- rejected artifact or diff
- reviewer reason
- desired behavior
- minimal reproduction task
- new deterministic check, model rubric rule, or human-escalation trigger

This is the compounding loop: human review should shrink future review load.

## Output Template

When asked to design an eval approach, return:

```markdown
## Eval Strategy

### Goal
[What quality or risk bottleneck this eval system reduces]

### Golden Tasks
- [Task category]: [source of examples, expected count]

### Grader Layers
| Layer | Checks | Tooling / owner |
| --- | --- | --- |
| Deterministic | ... | ... |
| Model judge | ... | ... |
| Human | ... | ... |

### Escalation Rules
- ...

### Metrics
- pass@1 / pass@3
- human review minutes per accepted output
- judge-human agreement rate
- defect escape rate
- cost and latency per accepted output

### Next 3 Steps
1. ...
2. ...
3. ...
```

## Patterns

- **Bug found** -> add a regression eval before or alongside the fix.
- **Reviewer disagreement** -> split one vague rubric item into two concrete checks.
- **Slow review queue** -> add risk routing and sampled audit.
- **LLM judge too generous** -> require evidence quotes and calibrate against human-labeled failures.
- **Prompt/model change** -> run golden tasks and compare quality, cost, latency, and human-escalation rate.

## Related Skills

- Use `eval-harness` for pass@k, eval definitions, and concrete eval reports.
- Use `ai-regression-testing` when the evaluation target is AI-authored code and recurring implementation bugs.
- Use `code-review-and-quality` or `security-review` when the human escalation target is code correctness or security.
