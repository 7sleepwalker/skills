# Roadmap

Live plan for this repo. Update it in the same commit as the work it describes.
Decisions that change *how the repo works* go in an ADR under [.agents/adr](./.agents/adr), not here.

## Now

- [ ] Phase 4: publish the repo to GitHub as public, verify the plugin install path on a second machine

## Next

- [ ] Fill in `docs/`-style usage notes only if a skill turns out to need more than its `SKILL.md`
- [ ] Add skill evals once `claude plugin eval` leaves early access (not enabled in-session yet). Schema captured: cases at `skills/<bucket>/<name>/evals/<case>/prompt.md` (frontmatter `name`, `tags`, `runs`, `max_turns`, `allowed_tools`, `model`) + `evals/<case>/graders/<name>.md` (`type:` regex | tool_used | tool_order | file_exists | llm | baseline; `target:` last_message | trace | files). Run `claude plugin eval . --allow-tools Bash Write`; results at `<eval-dir>/results/<ts>/aggregate-result.json` + `report.html`, exit 0 = all cases ≥ `--threshold` (default 1.0). Seed `code-review` + `baking` first. Source: Anthropic skill-creator.

## Open questions

- Is `writing-for-agents` (portable technique) worth keeping separate from `.agents/writing-skills.md` (house rules), or should one absorb the other?
- Manual `plugin.json` version bumps: good enough, or worth a release script later?

## Done

- 2026-09-01 Script polish: `unlink-skills.sh` now unsets `core.hooksPath` (symmetry with `link-skills.sh`, guarded so a custom value survives) and still runs when the skills dir is already gone; `list-skills.sh` gained a trimmed description column.
- 2026-09-01 Added a tracked `.githooks/pre-push` that runs `check-manifest.sh` and blocks the push on failure (ADR-0008); `link-skills.sh` enables it via `core.hooksPath`. Turns the "check before push" discipline into real enforcement — no CI on this machine.
- 2026-09-01 `code-review` diff scoping: the scope agent (S) now runs on the changed-files list + `--stat` + PR/ticket text instead of the full code diff — it judges intent vs what changed, not the code, so this saves ~1× full diff per run with no quality loss. Q1/Q2/R still read the full diff.
- 2026-09-01 `check-manifest.sh` now enforces the plain-language clause (ADR-0006): every promoted skill must carry the `**Plain language.**` marker with the canonical wording, closing the silent-drift gap the ADR had flagged.
- 2026-09-01 Cut `code-review` token burn: extract repo rules once into a verbatim digest (was re-read by every subagent) and paste it only to the agents that use it — Q1 all, Q2 the utils/test subset, R/S none (ADR — code-review Step 0/2).
- 2026-09-01 Dropped the per-skill `Adapted from …` footers (ADR-0007); the skills are standalone rewrites now, and `CREDITS.md` is the single place attribution lives. README + `writing-skills.md` reworded off "adapted" framing.
- 2026-09-01 Plain-language output (ADR-0006): every promoted skill now carries a self-contained clause telling the agent to write person-facing output for a non-native English reader (short sentences, common words, no idioms; technical terms + code kept exact). Authoring rule added to `writing-skills.md`.
- 2026-09-01 Hardened `code-review`: moved the `--html` layout spec to a `html-report.md` companion (leaner SKILL.md), added a big-PR guard in pre-flight (churn-rank + review top files when the diff is huge, never silent), reframed the confidence bar as a coarse band not a precise metric. Also gave `smells.md` a third binding rule — only raise a smell the diff can evidence (skip paradigm-mismatched and history-dependent smells).
- 2026-08-29 Renamed `code-quality` → `code-review` and split posting out of it: new user-invoked `comment-on-pr` reviews via `code-review`, then posts each finding as a gated inline PR comment (`gh api .../pulls/N/comments`) in a plain human voice. Dropped `--post` from `code-review`.
- 2026-08-29 Learned from `awesome-agent-skills`: `baking` gained lettered options + per-question "not sure" (no accept-all); `code-quality` gained blast radius + git-blame regression context (adapted from trailofbits/skills `differential-review`). Evals parked in Next.
- 2026-08-28 Namespaced every promoted skill under `boo:` via a skills-directory plugin (ADR-0005); `link-skills.sh` now makes one link to the repo root, private skills keep bare links
- 2026-08-28 Merged `caveman-review` severity prefixes and the `mattpocock/code-review` Fowler smell baseline into `code-quality`; added `smells.md`, a `q` category, and the two-axis rule

- 2026-08-25 Added `bake-with-jira`: pick a Jira ticket assigned to me, recon the repo, run the `baking` interview, hand off to plan mode
- 2026-08-24 Phase 3: adapted `baking`, `bake-it`, `diagnosing-bugs`, `handoff`, `writing-for-agents`; added `CREDITS.md`, bucket READMEs, root README, plugin + marketplace manifests
- 2026-08-24 Phase 2: migrated `code-quality` into `skills/engineering/` (`Task` -> `Agent` tool rename); linked all six skills into `~/.claude/skills`
- 2026-08-24 Retired `review`: no frontmatter, and every section it covered is a strict subset of `code-quality`. Deleted rather than migrated
- 2026-08-24 Phase 1: conventions (`AGENTS.md`, `.agents/invocation.md`, `.agents/writing-skills.md`) and scripts (`link-skills.sh`, `unlink-skills.sh`, `list-skills.sh`, `check-manifest.sh`)
- 2026-08-24 Phase 0: repo scaffold, MIT license, gitignore, roadmap, ADRs 0001-0004
