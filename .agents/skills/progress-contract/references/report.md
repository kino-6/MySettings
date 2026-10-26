# The report itself

The cadence rules cover what is owed *during* the work. This covers the message
that ends it - the one the person actually has to read.

**A report's job is to lower the reader's load.** Measure it by how fast the
reader gets what they need, not by how much was written. AI-written reports are
widely found long and hard to read; the person ends up doing the summarising the
agent should have done.

## Where this came from

Two local repositories had already paid for it, independently:

- `steering-health-intelligence/.claude/skills/report` - written after "使えない
  新人と会話しているようだ". Conclusion first (BLUF / Minto), outcome not activity,
  body within ten lines, file and script names last.
- `cdda-musou/.claude/skills/report` - written after "作業報告じゃなくて、
  マイルストーンに対して、簡潔に報告するようにしてほしい". "4 行で足りる"; the work
  list only when asked; corrections in one or two sentences without excuses.

The lesson that decides the design is steering's: **"この Skill は既に存在して
いたのに守れなかったので、型を機械で検査する形にした."** The skill alone was not
followed. Hence the optional Stop hook below.

Measured on this skill's own author before writing it - 36 end-of-turn reports in
one session: median 1,071 characters (p90 2,150), 14 over 1,200 characters, and
**"——" insertions 111 times across 26 of the 36**. "X ではなく Y" appeared in 14.
Two were written in English to a user writing Japanese.

The user then narrowed the complaint: emphasis (bold, colour) is fine; **volume
and phrasing** are the burden. Bold was dropped from the rules and the check.

Phrasing has local prior art too. `steering-health-intelligence/TROUBLES.md`
type T39, after "レポートの記述が気持ち悪すぎる…平易な日本語使ってほしい":
inversion, parallelism, nominal endings and "——" insertions. "飾りは意味を足さず、
読む速度だけを落とす." A machine check there found 267 lines of existing docs
using "——".

## Rules

1. **Answer in the first one or two sentences** - what happened, in the reader's
   terms. Not the order you did things in.
2. **A list of what you did is not a report.** Checks that passed are the
   expectation, not news; "lint ok, links ok, mirrors synced" is noise. Report
   what failed, what changed, and what needs a decision.
3. **Short by default.** Around ten lines of body for routine work. Longer only
   when the person asked for detail, or a decision genuinely needs it.
4. **Plain phrasing.** No inversion, parallelism, nominal endings or "——"
   insertions; no closing aphorism; do not lean on "X ではなく Y". One thing per
   sentence - split a long one in two. Decoration adds no meaning and only slows
   the reader.
5. **Plumbing last, one line** - commit, branch, file paths.
6. **Corrections in one or two sentences**, at the top only if they change a
   decision. No apology, no account of how the mistake happened.
7. **At most one question, at the end**, and only if it blocks.
8. **Write in the person's language.** Switching mid-session is a defect.
9. **No coined terms.** A label you invented this session means nothing to the
   reader; say the thing.

Mid-work status lines (the cadence rules) are not reports. They are one line
each. The report comes once, when the work is done.

## A default shape

For substantial work, not for a quick answer:

```
<1-2 sentences: what is now true>
<only if needed: the one decision the person has to make>
<only if needed: 2-3 lines of grounds>
<last line: commit / files>
```

If it does not fit, the work probably has not converged yet - that is worth
saying instead of writing around it.

## The mechanical check

`scripts/report_check.py` is a Claude Code `Stop` hook. It reads the turn's
final message (`last_assistant_message`) and, when the message is long and
over-structured, sends **one** revision request back as `additionalContext`.
It checks only what can be checked with high precision: length, heading count,
"——" insertions, repeated "ではなく", and language. Emphasis is not checked. It
does not judge whether the answer comes first; that stays with the rules above.

It is one-shot by construction: when `stop_hook_active` is true the agent is
already revising because of a stop hook, and the check lets it stop whatever
the result. Claude Code also caps consecutive stop-hook continuations at eight.

Each trigger costs one extra model turn, so thresholds are set to catch the
egregious reports, not the median one. Tune with environment variables:
`REPORT_MAX_CHARS` (1500), `REPORT_MAX_HEADINGS` (4), `REPORT_MAX_DASH` (1),
`REPORT_MAX_DEWANAKU` (2), `REPORT_LANG` (`ja`; set empty to disable).
Against the 36 reports above it would send back 24 (66%), 23 of them for "——".

Install in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {"hooks": [{"type": "command",
                  "command": "python3 ~/.claude/skills/progress-contract/scripts/report_check.py"}]}
    ]
  }
}
```

## Installed (2026-10-27): language check only

After the language rule was loaded, 5 of 28 replies of 100+ characters were still
in English and the user had to ask for Japanese three times. The other checks
were no longer firing much, so the hook is installed with `REPORT_CHECKS=lang`:

```
REPORT_CHECKS=lang python3 ~/.claude/skills/progress-contract/scripts/report_check.py
```

It sees only `last_assistant_message`, so mid-work status lines are untouched -
the user reads only the final reply. Verified end to end with `claude -p`: the hook
fired (30 ms) and its feedback reached the model. That test asked for English
explicitly, and the model rightly kept English; the feedback now says so.
`scripts/rule-eval/run.sh` sets `REPORT_LANG=""` so measurements are not skewed.

