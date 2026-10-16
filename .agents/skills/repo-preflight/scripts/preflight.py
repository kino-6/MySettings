#!/usr/bin/env python3
"""Pre-flight a git repository for secrets, personal data and risky files.

Reports only. Never edits .gitignore, never untracks, never rewrites history:
every action it suggests needs the user's confirmation first.

Each finding is classified by the state that decides what can fix it:

  untracked  not yet in git      .gitignore prevents it
  tracked    committed now       .gitignore does NOT help; needs git rm --cached
  history    only in past commits  ignore and rm do nothing; rotate the secret

Matched secret values are masked in the report (first 4 characters and length)
so the report cannot re-leak them into a transcript or a log.

Standard library only, no network.

  python3 preflight.py                 tracked + untracked files
  python3 preflight.py --history       also scan every commit for secrets
  python3 preflight.py --json          machine-readable
  python3 preflight.py --allow FILE    allowlist (default .preflight-allow)
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import re
import subprocess
import sys

MAX_TEXT = 1_000_000          # bytes; larger files are listed, not read
LARGE = 5_000_000             # bytes; flagged for review as large binaries

# --- secret values (high) -------------------------------------------------
SECRETS = [
    ("aws-access-key", r"\bAKIA[0-9A-Z]{16}\b"),
    ("github-token", r"\b(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36}\b"),
    ("github-pat", r"\bgithub_pat_[A-Za-z0-9_]{22,}\b"),
    ("anthropic-key", r"\bsk-ant-[A-Za-z0-9_-]{20,}"),
    ("openai-key", r"\bsk-(?:proj-)?[A-Za-z0-9]{32,}\b"),
    ("xai-key", r"\bxai-[A-Za-z0-9]{20,}\b"),
    ("slack-token", r"\bxox[abprs]-[A-Za-z0-9-]{10,}"),
    ("google-api-key", r"\bAIza[0-9A-Za-z_-]{35}\b"),
    ("private-key-block", r"-----BEGIN (?:RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----"),
    # env-style names: API_TOKEN, DB_PASSWORD, SECRET_KEY. `\b` would miss these,
    # because `_` is a word character and leaves no boundary before TOKEN.
    ("assigned-secret",
     r"""(?i)(?<![A-Za-z0-9])[A-Za-z0-9_]*(?:api[_-]?key|secret|token|passw(?:or)?d)[A-Za-z0-9_]*["']?\s*[:=]\s*["']?([A-Za-z0-9_+/=-]{16,})"""),
]
# The generic pattern is a net, not a guarantee. A value must look like a
# credential - letters and at least one digit - or `password_field = CharField`
# style code would drown the report.
GENERIC = {"assigned-secret"}

# --- personal data (medium) -----------------------------------------------
PERSONAL = [
    ("home-path", r"(?:/Users|/home)/[A-Za-z0-9._-]+/|[A-Za-z]:\\Users\\[A-Za-z0-9._-]+\\"),
    ("email", r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b"),
    ("jp-phone", r"\b0[789]0-\d{4}-\d{4}\b|\b0\d{1,3}-\d{2,4}-\d{4}\b"),
]
# home directories that name no one: placeholders in docs and upstream tests
PLACEHOLDER_USERS = {"user", "username", "you", "yourname", "me", "runner", "name",
                     "example", "someone", "foo", "jdoe", "admin", "ubuntu", "vagrant"}
HOME_USER = re.compile(r"(?:/Users|/home)/([A-Za-z0-9._-]+)/|[A-Za-z]:\\Users\\([A-Za-z0-9._-]+)\\")
# addresses that identify no person
EMAIL_OK = re.compile(
    r"(?i)@(?:example\.(?:com|org|net)|users\.noreply\.github\.com|noreply\.[a-z.]+)$"
    r"|^(?:noreply|no-reply|git|t)@"
)

# --- file names (state decides the fix) -----------------------------------
RISKY_NAMES = [
    ("high", "env-file", [".env", ".env.*"], [".env.example", ".env.sample", ".env.template"]),
    ("high", "key-file", ["*.pem", "*.key", "*.p12", "*.pfx", "*.keystore", "id_rsa*", "id_ed25519*", "id_ecdsa*"],
     ["*.pub"]),
    ("high", "credentials", [".netrc", "credentials*.json", "service-account*.json", "*.credentials", ".pgpass"], []),
    ("medium", "local-config", ["*.local.json", "*.local.toml", "*.local.yaml", "*.local.yml", "settings.local.*"], []),
    ("medium", "database", ["*.sqlite", "*.sqlite3", "*.db", "*.dump", "*.sql.gz"], []),
    ("medium", "session-log", ["history.jsonl", "*.transcript.*", "*.log"], []),
    ("low", "paid-material?", ["*.pdf", "*.epub", "*.mobi", "*.azw3"], []),
    ("low", "os-noise", [".DS_Store", "Thumbs.db"], []),
]


def git(*args: str) -> str:
    out = subprocess.run(["git", *args], capture_output=True, text=True, errors="replace")
    if out.returncode != 0:
        sys.exit(f"git {' '.join(args)} failed: {out.stderr.strip()}")
    return out.stdout


def plausible(value: str) -> bool:
    return any(c.isdigit() for c in value) and any(c.isalpha() for c in value)


def mask(value: str) -> str:
    v = value.strip()
    return f"{v[:4]}…({len(v)} chars)" if len(v) > 4 else "…"


def load_allow(path: str) -> list[str]:
    if not os.path.isfile(path):
        return []
    pats = []
    for line in open(path, encoding="utf-8"):
        line = line.split("#", 1)[0].strip()
        if line:
            pats.append(line)
    return pats


def allowed(path: str, line: int | None, allow: list[str]) -> bool:
    for pat in allow:
        if ":" in pat and not pat.startswith("*"):
            p, _, ln = pat.rpartition(":")
            if ln.isdigit() and line is not None and fnmatch.fnmatch(path, p) and int(ln) == line:
                return True
            continue
        if fnmatch.fnmatch(path, pat) or fnmatch.fnmatch(os.path.basename(path), pat):
            return True
    return False


def name_findings(path: str) -> list[dict]:
    base = os.path.basename(path)
    out = []
    for sev, kind, pats, excepts in RISKY_NAMES:
        if any(fnmatch.fnmatch(base, e) for e in excepts):
            continue
        if any(fnmatch.fnmatch(base, p) for p in pats):
            out.append({"severity": sev, "kind": kind, "path": path, "line": None, "evidence": base})
    return out


def content_findings(path: str, text: str) -> list[dict]:
    out = []
    for n, line in enumerate(text.splitlines(), 1):
        for kind, pat in SECRETS:
            for m in re.finditer(pat, line):
                val = m.group(1) if m.groups() else m.group(0)
                if kind in GENERIC and not plausible(val):
                    continue
                out.append({"severity": "high", "kind": kind, "path": path, "line": n, "evidence": mask(val)})
        for kind, pat in PERSONAL:
            for m in re.finditer(pat, line):
                val = m.group(0)
                if kind == "email" and EMAIL_OK.search(val):
                    continue
                if kind == "home-path":
                    hm = HOME_USER.match(val)
                    who = (hm.group(1) or hm.group(2)) if hm else ""
                    if who.lower() in PLACEHOLDER_USERS:
                        continue
                shown = val if kind == "home-path" else mask(val)
                out.append({"severity": "medium", "kind": kind, "path": path, "line": n, "evidence": shown})
    return out


def scan_files(paths: list[str], state: str, self_path: str) -> list[dict]:
    found = []
    for p in paths:
        if not p or os.path.abspath(p) == self_path or not os.path.isfile(p):
            continue
        for f in name_findings(p):
            f["state"] = state
            found.append(f)
        size = os.path.getsize(p)
        if size > LARGE:
            found.append({"severity": "low", "kind": "large-file", "path": p, "line": None,
                          "evidence": f"{size // 1_000_000} MB, not read", "state": state})
        if size > MAX_TEXT:
            continue
        try:
            with open(p, "rb") as fh:
                raw = fh.read()
        except OSError:
            continue
        if b"\0" in raw[:4096]:
            continue
        for f in content_findings(p, raw.decode("utf-8", errors="replace")):
            f["state"] = state
            found.append(f)
    return found


def scan_history(current: set[str]) -> list[dict]:
    """Secrets present in some past commit. Only secrets: PII in history is too noisy."""
    log = git("log", "--all", "-p", "--no-color", "--format=COMMIT %h")
    found, seen = [], set()
    commit, path = "", ""
    for line in log.splitlines():
        if line.startswith("COMMIT "):
            commit = line.split()[1]
        elif line.startswith("+++ b/"):
            path = line[6:]
        elif line.startswith("+") and not line.startswith("+++"):
            for kind, pat in SECRETS:
                for m in re.finditer(pat, line[1:]):
                    val = m.group(1) if m.groups() else m.group(0)
                    if kind in GENERIC and not plausible(val):
                        continue
                    key = (kind, val, path)
                    if key in seen:
                        continue
                    seen.add(key)
                    found.append({"severity": "high", "kind": kind, "path": path, "line": None,
                                  "evidence": f"{mask(val)} in {commit}", "state": "history",
                                  "_value": val})
    return found


ACTION = {
    "untracked": "add to .gitignore (prevents it)",
    "tracked": "git rm --cached <path> + .gitignore (still in history)",
    "history": "rotate the credential; rewriting history needs filter-repo + force-push",
}
# Personal data usually sits in a file that is meant to be there (an inventory,
# a README), so untracking the file is the wrong default - redact the line.
PERSONAL_KINDS = {"home-path", "email", "jp-phone"}
PERSONAL_ACTION = "redact in place (e.g. home path -> ~); untrack only if the file has no purpose"


def action_for(f: dict) -> str:
    if f["kind"] in PERSONAL_KINDS and f["state"] == "tracked":
        return PERSONAL_ACTION
    return ACTION[f["state"]]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--history", action="store_true", help="also scan every commit for secrets")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--allow", default=".preflight-allow")
    args = ap.parse_args()

    os.chdir(git("rev-parse", "--show-toplevel").strip())
    self_path = os.path.abspath(__file__)
    allow = load_allow(args.allow)

    tracked = git("ls-files").splitlines()
    untracked = git("ls-files", "--others", "--exclude-standard").splitlines()
    findings = scan_files(tracked, "tracked", self_path) + scan_files(untracked, "untracked", self_path)

    if args.history:
        live_values = set()
        for f in findings:
            live_values.add((f["kind"], f["path"]))
        for f in scan_history(set(tracked)):
            # a secret still present in the working copy is reported as tracked already
            if (f["kind"], f["path"]) in live_values:
                continue
            f.pop("_value", None)
            findings.append(f)

    findings = [f for f in findings if not allowed(f["path"], f["line"], allow)]
    order = {"high": 0, "medium": 1, "low": 2}
    findings.sort(key=lambda f: (order[f["severity"]], f["state"], f["path"], f["line"] or 0))

    if args.json:
        print(json.dumps(findings, ensure_ascii=False, indent=2))
    else:
        if not findings:
            print("PREFLIGHT CLEAN" + (" (history included)" if args.history else ""))
        for sev in ("high", "medium", "low"):
            group = [f for f in findings if f["severity"] == sev]
            if not group:
                continue
            print(f"\n== {sev.upper()} ({len(group)}) ==")
            for f in group:
                loc = f"{f['path']}:{f['line']}" if f["line"] else f["path"]
                print(f"  [{f['state']:9}] {f['kind']:18} {loc}  {f['evidence']}")
                print(f"              -> {action_for(f)}")
        n = {s: sum(f["severity"] == s for f in findings) for s in order}
        print(f"\nPREFLIGHT high={n['high']} medium={n['medium']} low={n['low']}"
              + ("" if args.history else "  (history not scanned; add --history)"))
        print("Nothing was changed. Every action above needs the user's confirmation.")
    return 1 if any(f["severity"] == "high" for f in findings) else 0


if __name__ == "__main__":
    sys.exit(main())
