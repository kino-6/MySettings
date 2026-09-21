# The trouble registry

**Load this when** the same class of mistake keeps coming back, when a
conclusion or a report is about to be written, or when a project's lessons file
has grown into something nobody reads.

The loop's other structural hole. The gate audit catches a bad gate on one row;
this catches the mistake you will make again on the next twenty. Distilled from
`steering-health-intelligence/TROUBLES.md` (1371 lines, 46 types, mechanically
enforced), `cdda-musou/docs/LEARNED.md` (1167 lines, 33 entries, generalised into
its `gate` skill), and `rustbound/docs/trouble-log.md` (385 lines).

## The one idea

> **個別の事象は二度と起きない。型は何度でも起きる。**
> A specific incident never happens twice. The *type* happens over and over.

So the registry does not store incidents. It stores **types**, each with a
recurrence count, sorted by count. `steering-health-intelligence` has 46 types;
the top one has fired **11 times**, and five types have fired more than twice.
A count of 7 next to "breaks the stated constraint" is an argument that
attention alone was never going to fix it.

The generalisation step is the whole value, and it is visible in
`rustbound/docs/trouble-log.md`: nine complaints from one play session were not
nine fixes, they were **six types** - a regression suite that had frozen display
text, point measurements read as curves, options silently dropped by an
unknown-key branch, and so on. Nine fixes would have shipped the same six
mistakes again next month.

## Type entry shape

```md
| 型 | 何をやったか | 回数 |
|---|---|---|
| **T14 「無い・使い切った・網羅した」と早く言い切る** | 探索が尽きていないのに、尽きたと書いた | **11** |
```

Then, per type, the longer form when it earns it:

- **症状** - what it looked like from outside
- **原因** - the mechanism, not the incident
- **修正** - what was done this time
- **再発防止** - the check that would have caught it, phrased so it can be run

Keep a numbered row per occurrence with a link to the document where it
happened. The row that says "4th time: X" is what makes the count credible.

## Writing it down must not depend on remembering

> **2026-09-01 ユーザ指摘: 「正直人間側が指摘できない」。**

That sentence is the design constraint. A registry maintained by good intentions
records the failures you were already alert to, which are the ones you did not
need a registry for. The working split:

- **Appending is automatic.** A pre-commit hook (`scripts/sync_troubles.py`)
  scans the commit for any document declaring a correction, a withdrawal, or a
  failed prediction, and appends the ones missing from the registry into an
  **unclassified** section, staged by that same commit. Nothing is lost between
  noticing and recording.
- **Classifying is manual, and it blocks.** `check_repo.py`'s
  `troubles classified` refuses to let the commit through while the unclassified
  section is non-empty. Moving the row under an existing type (and bumping its
  count) or opening a new type is a judgement call, so the machine demands it
  rather than guessing.
- **A second gate, `troubles registered`, blocks any commit whose document
  declares a retraction that is not in the registry at all.**

Writing down is automatic; deciding what type it is, is not. That is the line.

## Recall must not depend on remembering either

The registry is useless if loading it is a habit. Two mechanisms, both cheap:

- **Digest at session start.** `scripts/troubles_digest.py` runs from a
  `SessionStart` hook and puts the type list into context before any work
  begins. Nobody has to think of the skill.
- **A paired checklist skill, run before conclusions.** Not the registry itself -
  a skill that walks the types in order of frequency and asks the one question
  that would have caught each. `cdda-musou`'s `gate` skill is the same pattern
  built from a different registry:

  > このリポジトリで**同じ失敗を4回以上繰り返した**ので、着手前に必ず通す。
  > 出どころは docs/LEARNED.md（33件）。

  Its checks read as questions, not warnings: "その値は、結果に至る経路のどこに
  入っている? 経路を1本たどれないなら、振る前にたどる." That is a check someone
  can actually run before touching a number.

## What the checklist should ask

Order by recurrence count, most frequent first, and phrase every item as a
question with a concrete action attached. The most valuable entries in the two
mature registries, generalised:

- **"There is none / I have exhausted it / that is all of them."** Before writing
  "none", change one axis of the search and look again - in three recorded cases
  changing the axis found it. And write "not found along this axis", because the
  subject of the sentence is your search, not the world.
- **Reporting your work instead of the answer.** Does the first sentence answer
  the question that was asked, or describe what changed since last time?
- **Your own assumption reported as evidence.** Can you say in one line who chose
  that range, that constant, that grid? If it was you, say so in the report.
- **A quantity mistaken for a different quantity.** Can you say what is in the
  numerator and the denominator? Does the name match what is measured?
- **A number carried outside the conditions it was measured under.** Is the
  measurement condition written in the same sentence as the number?
- **Speaking about the whole from a slice of the sample.** Did you open the top
  few rows and actually look before writing the count?
- **A pass condition that must hold, or must fail, by construction.** Compute it
  once before registering it - a prediction you could have calculated is not a
  prediction.
- **Marking your own task done before reading the spec it claims to satisfy.**

Split the list by what a machine can decide. `steering-health-intelligence`
sends five of its types to `check_repo.py` (wording, dataset coverage, sheet
currency, float comparisons, report shape) and leaves the rest as judgement
calls with explicit sub-questions. **Move a type to the machine the moment it can
be decided mechanically** - that is the only way the human-judgement list stays
short enough to actually be read.

## How it plugs into the lap

- Lap entry (step 1-2): the session-start digest is already in context, so the
  types are present before the first decision.
- Before writing any conclusion, report, or `[x]`: run the checklist skill.
- When a row turns out to have been closed on a false premise: the retraction
  document triggers the hook, the entry lands unclassified, and the commit
  blocks until it is filed under a type. The audit's `GATE_BROKEN` verdicts are
  a natural feeder for this.

## Limits, stated plainly

- **The registry contains only the failures you noticed.** Types you cannot see
  are not in it, and their absence proves nothing.
- **A checklist is not sufficient.** In the mature registry, type T1 recurred a
  fourth time *after* its corrective procedure was written and followed. The
  count going up is the system working, not the system failing - but do not read
  a full checklist as coverage.
- **Do not mix pre-registered negative results into the counts.** A prediction
  that was registered and then failed is a result, not a trouble; it gets its
  own section.
