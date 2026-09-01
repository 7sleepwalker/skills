# 0007. Drop per-skill attribution footers

Amends [0004-adapt-not-vendor.md](./0004-adapt-not-vendor.md). That decision stands — skills are still read-for-technique and rewritten, never vendored. Only the *shape* of attribution changes.

## Context

ADR-0004 required each adapted skill to carry two attributions: a row in `CREDITS.md` and a footer in the skill file (`Adapted from [mattpocock/skills] (MIT)`).

Since then the skills have diverged far from where they started. `code-review` merged three sources and grew its own smell baseline, two-axis rule, blast-radius severity, and scope axis; `baking`, `handoff`, and the rest were rewritten to this repo's voice and conventions. Calling them "adaptations" on every file undersells them and adds a line of noise to skills that now stand on their own.

The footer was also duplicated obligation: `CREDITS.md` already lists every source with the exact license and what was taken. Two places to keep accurate is one too many, and the footer is the one that drifts.

## Decision

Remove the `Adapted from …` footer from every `SKILL.md`. `CREDITS.md` is the single place attribution lives.

- Every skill that started from prior work keeps its `CREDITS.md` row — nothing is dropped from there.
- The authoring rule in [../writing-skills.md](../writing-skills.md) now says "credit in `CREDITS.md`, no footer."
- New skills follow the same rule: a row if they started from someone else's work, never a footer.

## Consequences

- **License obligations still met.** MIT (mattpocock, caveman) and CC-BY-SA-4.0 (trailofbits) attribution are all carried by `CREDITS.md`, which names each source, its license, and what was taken. Removing an in-file footer while keeping the credits file satisfies both licenses; the trailofbits row already notes the work is technique-only and rewritten, so no share-alike derivative attaches.
- `CREDITS.md` becomes load-bearing — it must stay accurate, since it is now the only record. Losing it would be losing the attribution.
- Skill files read as standalone works, which is what they are.
- Reverting is `git revert` of the introducing commit; the footers come back with it.
