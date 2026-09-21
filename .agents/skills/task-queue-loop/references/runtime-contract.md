# The agent-operable runtime contract

**Load this when** the lap's step 6 ("verify it yourself") is hard or impossible:
the project has no single launch command, running it steals the human's window,
results are not reproducible from a screenshot, or verification has to wait for
the human to stop playing.

Step 6 is the load-bearing step of the loop, and it silently degrades into
"headless pass, ship it" whenever the runtime makes real observation expensive.
This is the contract that keeps it cheap. Distilled from the launchers actually
in use locally: `cdda-musou/run.sh` (551 lines), `black-stela/run.sh` (404),
`ecliptica/run.sh` (309), `rustbound/Run.sh` (264).

## 1. One entry point, and it cannot lie

**The only thing anyone memorises is `./run.sh`.** Every lane - play, test,
capture, gate, probe, stop - hangs off it. No lane is reachable only by
remembering a raw `godot --headless --path . -- --autoplay=...` invocation.

**Derive the help from the code.** `black-stela/run.sh` reads its fixture, gate,
and route lists out of the source each time it prints them, so the script cannot
go stale and start advertising lanes that no longer exist. A hand-maintained
usage block is a second reader of the same question (see "one reader per
question" in the main skill) and it drifts first.

Corollary, found by the audit run in this repo: **a lane that is not in the usage
block does not exist for a fresh session.** `rustbound`'s `Run.sh script` is used
by a Tasks.md row as its repro command but is absent from the usage header, so
nobody reading the launcher would know to run it.

## 2. Machine runs never touch the human's state

Three separations, all of them load-bearing:

- **Exclusive lock.** Serialise runs that fight over a shared cache. `rustbound`
  locks because concurrent Godot processes on one project directory contend for
  the `.godot` import cache and hang. The lock waits; it does not kill.
- **Run scope.** Machine lanes write under their own scope
  (`--run-scope=autoplay-<route>`, a separate user-data dir) so a test run can
  never overwrite the player's save.
- **Shadow tree.** When the human is playing, verification must not queue behind
  them. `tools/shadow.sh` rsyncs the working tree to `/tmp/<project>-shadow`
  (excluding `.git/`, the engine cache, and screenshots) and runs there with its
  own lock and user-data dir. Point the shadow dir somewhere else and two
  verification runs go in parallel - a single file rerun underneath a long gate.

**Never auto-`stop` the other session.** The lock owner may be a human playing.
`rustbound` T566 makes this explicit: when the agent is made to wait, it moves
to the shadow tree; it does not suggest killing whoever holds the lock.

## 3. The agent never takes the foreground

Agent lanes are **headless only**. This is not a preference; it was measured.

> macOS, 2026-09-13 (`ecliptica/run.sh`): a Godot that creates a window
> foregrounds the app for about 0.5s at startup. Setting
> `display/window/size/no_focus=true` before window creation *and* launching via
> `open -gjW -n` (hidden, background) does not remove it. `--headless` never
> foregrounds. Therefore the agent lanes are headless only.

Do the same measurement for your own engine and record the result next to the
launcher, because the conclusion is the reason the rule exists.

**Then enforce it as a gate.** `rustbound/tools/check_background_launch.sh` runs
the agent launcher and asserts the foreground app did not change and the window
stayed hidden. A window-focus rule that is only written down gets broken by the
next lane someone adds.

Anything that must create a window - a recording, a real-window screenshot - is
a **separate, explicitly-flagged lane that only runs when the human asks for it**
(`ecliptica`: `record-walk` and `window-evidence`, both gated behind
`ECLIPTICA_ALLOW_WINDOW=1`). Never in a gate, never on the agent's own initiative.

## 4. Capture without a window

The agent still has to look at real pixels. The working pattern: render the
production view headlessly, serve it locally, screenshot it at a fixed
resolution, save only the PNG (`rustbound/tools/capture_web.py`, 1920x1080). One
command, a named shot, no OS window:

```
./Run.sh capture <route> <shot> [--seed=N] [--event=id:stage]
```

Fixed resolution matters: it is what makes two captures comparable across laps,
and what lets a gate assert "the bottom edge is <= 720".

## 5. Seeds, and stamping them where they survive

**Every run takes `--seed=N`**, and a row's repro command names the seed it used.
Without it, "I saw it at seed 7" is not a reproduction.

**Put the version and the seed inside the frame**, not just in the title bar and
the log:

> `cdda-musou/docs/LEARNED.md` #25: "Hash や Version を画面に入れないと報告が
> すれ違うのでは?" - they were in the title bar and the log, **but a screenshot
> carries neither.** A small `<hash> · seed <n>` now sits at the right edge of
> the HUD.

Version = short SHA plus a dirty marker (`git rev-parse --short HEAD` + `+` when
the tree is not clean). `cdda-musou/run.sh` also writes the served version to a
per-port file, so a second session can see what is already running and say
"port 8081 is serving `a1b2c3+`, not touching it" instead of stepping on it.

## 6. Bounded runs, known log paths

Long observation lanes take a timeout and kill the process when it expires
(`./Run.sh probe <route> [seconds]`), always write to a known path
(`/tmp/<project>-run.log`), and print the tail on exit. An agent that has to
guess where the output went will stop looking at output.

Scan the log for silent failures and fail the run on them - `SCRIPT ERROR:`,
`Failed to load script`, leaked instances, `AUTOPLAY FAIL:`. A crash that only
appears as a line in a log the gate does not read is a green gate.

## 7. One command to show a state

`./Run.sh play --state=<name>`, a fixture name, a boot flag. This is the `再現:`
line every queue row owes, and it is the thing that makes "go look at it
yourself" a five-second operation rather than a play-through.

## Installing this in a repo

Work down the list and stop at the first one that is false; that is the cheapest
fix available:

1. Is there one entry point, and does `./run.sh` with no arguments explain itself?
2. Does its help come from the code?
3. Can a machine lane run while a human is playing?
4. Does any agent lane create a window? (Measure it, then gate it.)
5. Can the agent produce a real-pixel PNG in one command at a fixed resolution?
6. Does every run take a seed, and does the frame carry version and seed?
7. Do long runs time out, log to a known path, and fail on errors in the log?
8. Is there a one-command way to show any given state?
