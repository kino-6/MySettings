---
name: repo-preflight
description: Check a git repository for secrets, personal data and risky files before it goes public, gets a new remote, or is shared - and propose .gitignore / untrack / rotation fixes that run only after the user confirms. Use before publishing or pushing to a new remote, right after vendoring a third-party bundle, when a private repo has never been audited, or when the user asks whether anything sensitive is committed.
---

# Repo Preflight

Private repositories hide accidents: nothing goes wrong until the day the repo
is made public, given a second remote, or zipped up for someone. Run this before
that day, not after - and right after importing a third-party bundle wholesale,
which is the moment unread content arrives all at once.

**Report first, act only on confirmation.** The scanner changes nothing. Every
fix it suggests - an ignore line, an untrack, a history rewrite, a rotation - is
proposed to the user and done only after they say yes.

## What `.gitignore` can and cannot fix

This is the part most people get wrong, so say it in every report.

| State | What it means | Does `.gitignore` help? | The fix to propose |
|---|---|---|---|
| **untracked** | not in git yet | **yes** - it prevents it | add an ignore line |
| **tracked** | committed now | **no** - ignore never untracks | `git rm --cached <path>` + ignore line; it stays in history |
| **history** | in past commits only | **no** | rotate the credential; rewriting history is separate |

**A credential that was ever committed is compromised.** Untracking or ignoring
it does not un-leak it, and if it was ever pushed anywhere, assume it was read.
Rotate it at the provider first; cleaning git comes second.

## Run it

```bash
python3 <this skill>/scripts/preflight.py            # tracked + untracked
python3 <this skill>/scripts/preflight.py --history  # also every commit
```

Exit 1 if anything high-severity is found, so it can sit in a pre-push hook.
Standard library only, no network - consistent with auditing through readable
in-repo commands rather than a downloaded scanner.

It looks for:

- **secrets** (high): vendor key formats (AWS, GitHub, Anthropic, OpenAI, xAI,
  Slack, Google), private key blocks, and env-style assignments such as
  `API_TOKEN=` / `DB_PASSWORD:` / `SECRET_KEY =`
- **personal data** (medium): absolute home paths that leak a username, email
  addresses (noreply and example domains excluded), Japanese phone numbers
- **risky files**: `.env*` (not `.env.example`), key and keystore files,
  `.netrc` / credential JSON, `*.local.*` config, databases and dumps, session
  logs and transcripts, PDFs and ebooks (possible paid material), large binaries

**Matched secret values are masked** - first four characters and the length. Do
the same when you talk about them. Never paste a matched value into the chat, a
commit message, or an issue; that is how a report becomes a second leak.

## Presenting the findings

1. **Rank them and give each a verdict**, including "no action, because X" for
   the false positives. A flat list hands the triage back to the user.
2. **Group by state**, because the state decides the fix.
3. **Ask per item for secrets**; per group is fine for medium and low.
4. **Then act, only on what was confirmed** - ignore lines, `git rm --cached`.
5. **History rewriting and force-pushing are a separate question**, asked
   explicitly and never bundled with the ignore edits. They rewrite every
   collaborator's history and need coordination.

When an item is a false positive the user wants to keep, add it to
`.preflight-allow` with the reason after `#`:

```
docs/sample-config.md   # documentation example, not a credential
src/fixtures/*.pem:12   # test fixture key, generated, never used
```

## Limits - say these, do not hide them

- **Pattern matching is a net, not a guarantee.** The generic assignment pattern
  needs a value with letters and a digit, so an all-letter password slips
  through; vendor formats are much more reliable.
- **Personal data in history is not scanned** - it is too noisy to be useful.
  Only secrets are checked across commits.
- **Paid or copyrighted content cannot be recognised** beyond its file type.
  A distilled book in a public repo is a judgement call; ask.
- **Stronger tools exist** - `gitleaks` and `trufflehog` know far more formats
  and verify some keys live. They are worth it for a repo with real exposure,
  but installing a scanner is the user's decision, not something to run
  unprompted.

## Related

- `task-queue-loop/templates/hooks/pre-push` - this scan fits there, before the
  full run: a high finding stops the push.
- `security-review` - reviewing a diff for vulnerabilities. This skill is about
  what the repository contains, not whether the code is safe.
