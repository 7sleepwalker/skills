# 0006. Plain-language output

## Context

These skills are read and acted on by a non-native English speaker. When a skill's agent produces text a person reads — an interview question, a review finding, a summary, a report — dense or idiomatic English adds friction the technical content never needed.

Two facts shape the fix:

- **Skills ship to other repos** (plugin / symlink, see [0001-dual-distribution.md](./0001-dual-distribution.md)). There is no global preamble injected into every skill's runtime, and the project `CLAUDE.md` here does not travel. So any output rule that must hold at runtime has to live *inside the skill file*.
- **Terse is not the same as clear.** The house voice is terse (drop hedging, drop filler). For a non-native reader, telegraphic, idiom-heavy text can be harder, not easier. The two goals are reconciled by keeping sentences short and words common — not by adding words.

## Decision

Every promoted skill whose agent emits person-facing text carries a self-contained **Plain language** clause, worded canonically:

> Write anything a person reads — questions, findings, summaries, reports — for a non-native English speaker: short sentences, one idea each, common words, no idioms or phrasal verbs. Keep technical terms and proper names exact (`null-check`, `race`) and never simplify code. Clear over clever.

- The clause governs **output only**, never the skill prose itself. Skill prose still follows `writing-for-agents`.
- It is **inlined**, not linked — the skill must carry it when run in a repo that has never seen this ADR.
- Placement follows the skill: a bullet in an existing "Guardrails that never change" list where one exists (`code-review`, `comment-on-pr`), otherwise a standalone line after the intro.
- `writing-for-agents` scopes the clause to its **chat with the user** — the agent-facing docs it authors keep that skill's own dense rules.
- The authoring rule lives in [../writing-skills.md](../writing-skills.md); new skills inherit it there. `grep -rl '**Plain language.**' skills/` finds every copy.

## Consequences

- Output across the promoted set reads uniformly and stays approachable; technical terms and code are untouched.
- The canonical string is duplicated across ~8 files. That is deliberate — the alternative (a shared file) cannot travel with a shipped skill. `grep` keeps the copies findable if the wording is ever revised; a change means editing each copy.
- `check-manifest.sh` enforces the clause on every promoted skill: the `**Plain language.**` marker must be present and the canonical wording intact, so a missing or gutted clause fails the check. (The scoped `writing-for-agents` variant still passes — it keeps both checked strings.)
- Reverting is `git revert` of the introducing commit.
