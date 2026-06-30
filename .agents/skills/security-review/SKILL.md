---
name: security-review
description: Use when reviewing or auditing completed/proposed changes for vulnerabilities, secrets exposure, auth gaps, injection risks, and missing security tests. For implementation-time hardening, prefer security-and-hardening.
---

# Security Review

Use this skill from a reviewer posture: inspect a completed or proposed change
for security risks, missing tests, unsafe defaults, leaked secrets, weak auth,
injection paths, XSS/CSRF issues, sensitive data exposure, dependency risk, or
other vulnerabilities.

For designing or implementing sensitive behavior, use `security-and-hardening`
first. Load this skill when the question is "is this safe enough?"

## Workflow

1. Identify the assets, trust boundaries, user-controlled inputs, secrets, and
   externally visible actions touched by the change.
2. Review the diff and nearby code before applying generic checklists.
3. Prioritize exploitable risks and missing security tests over style issues.
4. Load `references/full-guide.md` for the full checklist and example tests.
5. Report findings with file/line references, severity, impact, and a concrete
   remediation.

## Reference

- `references/full-guide.md` preserves the original detailed guide with
  checklists and examples for secrets, validation, SQL injection, auth, XSS,
  CSRF, rate limiting, sensitive data, blockchain/Solana concerns, dependency
  security, automated tests, deployment checks, and external resources.
