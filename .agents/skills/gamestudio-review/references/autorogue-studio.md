# AutoRogue Studio Reference

Use this reference only when the request is about AutoRogue or a similar
automation-heavy roguelike.

## Experience Pillars

- **Readable automation**: The player should understand what the AI is trying to
  do by watching the screen and skim-reading the log.
- **Tactical rescue**: Scrolls, wands/staves, thrown items, and retreat should
  create believable ways out of bad rooms.
- **Rogue texture**: Identification, hidden information, traps, surprise rooms,
  and partial knowledge should matter without becoming pure noise.
- **Intervention tension**: Limited player intervention is interesting when the
  player sees a dangerous state, predicts the AI's likely failure, and chooses a
  build/tactic at the right time.
- **Spectator-first feedback**: HP bars alone are weak drama. Use danger tint,
  intent logs, projectile trails, room warnings, and clear cause/effect messages.

## Review Heuristics

Ask these questions before proposing work:

1. What does the player see before the bad thing happens?
2. What decision or interpretation is the player invited to make?
3. What tactical out exists if the AI or player is in trouble?
4. Is the outcome legible without reading a full debug log?
5. Does this add a new choice, a new readable surprise, or only more systems?

## Current Feature Context

Recent direction in AutoRogue includes:

- tactical item automation for scrolls and staves/wands
- item throwing for all non-gold inventory items
- thrown item landing/breaking behavior
- low-HP auto pause
- danger tint
- monster houses as dense encounter spikes
- Japanese-facing game text where it supports the game's authored feel

Treat traps as already present unless source says otherwise. New trap work
should usually focus first on encounter composition and readability, not adding
many trap types.

## Good Next-Slice Patterns

- "Make one dangerous event readable": add a clear log line, a visual cue, and a
  focused seed/test.
- "Make one tactical item valuable": define the situation, AI reason, outcome,
  and failure mode.
- "Make one encounter memorable": use room composition, warning, reward, and
  escape tools rather than raw enemy count only.
- "Make one headless report useful": add compact event summaries that explain
  pressure, not just totals.

## Anti-Patterns

- Adding broad systems before the player can perceive the current ones.
- Balancing only from aggregate headless numbers.
- Making AI smarter without showing intent.
- Over-identifying mystery items through perfect log text.
- Letting UI jitter or unreadable bars become the main source of tension.
