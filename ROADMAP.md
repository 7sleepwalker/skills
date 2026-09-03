# Roadmap

Live plan for this repo. Update it in the same commit as the work it describes.
Decisions that change *how the repo works* go in an ADR under [.agents/adr](./.agents/adr), not here.

## Now

- [ ] Phase 4: publish the repo to GitHub as public, verify the plugin install path on a second machine

## Next

- [ ] Fill in `docs/`-style usage notes only if a skill turns out to need more than its `SKILL.md`
- [ ] Run + expand skill evals. First seed drafted at `evals/bake-a-feature/` (baking: a `tool_used: Skill` fired-indicator + an `llm` grader for the interview behaviour). `claude plugin eval` ships in the CLI, but *running* is still gated ("plugin eval is currently in early access"), so the seed is unverified until the gate opens. Then seed `code-review` too and wire `.github/workflows/check.yml` to run them. Schema: cases at `evals/<case>/prompt.md` (frontmatter `name`, `tags`, `plugins`, `runs`, `max_turns`, `allowed_tools`, `model`) + `graders/<name>.md` (`type:` regex | tool_used | tool_order | file_exists | llm | baseline; `target:` last_message | trace | files); ablation runs with/without arms; `claude plugin eval . --allow-tools Bash Write`; exit 0 = all cases ≥ `--threshold` (default 1.0). Source: Anthropic skill-creator.

## Open questions

_None open._

## Done

- 2026-09-03 Cross-agent distribution (ADR-0010): `link-skills.sh` now also symlinks every skill into `~/.agents/skills` (the generic cross-agent dir), and `unlink-skills.sh` clears them symmetrically. This is the delivery half of the agent-agnostic goal — bodies were already portable (ADR-0009); the links make agents that read `~/.agents/skills` load the same skills, symlinks not copies (nothing to rot). `AGENTS.md`/`README.md` updated. The whole agent-agnostic goal (content + delivery) is now done.
- 2026-09-03 Completed the agent-agnostic rollout across the promoted set. `bake-it`, `bake-with-jira`, `comment-on-pr`, `handoff` converted: cross-skill `Skill` calls → method references ("apply the *<name>* method"), and `Agent`/`AskUserQuestion`/plan-mode/atlassian-MCP wrapped as optional "on Claude Code" layers over portable defaults. Every remaining tool name now sits in frontmatter `allowed-tools` or inside a conditional. Only `AGENTS.md` distribution (delivery) is left — see Now.
- 2026-09-03 Agent-agnostic authoring (Q1a + Q3b): added a `## Portability` section to `writing-for-agents` (capability vocabulary — "search the codebase" not `Grep`, "spawn parallel workers" not the `Agent` tool, "apply the *<name>* method" not a `Skill` call — plus the conditional-layering rule) and a matching "name capabilities, not tools" line in `.agents/writing-skills.md`. Pilot: converted `code-review`'s fan-out to capability-first (sequential spine, parallel workers an optional accelerator), renamed its Claude-only "agents" to "passes", and fixed the resulting "pass" vs pass/fail collision. `baking` confirmed already portable (one `grep`→"search" tweak). The decision is recorded in ADR-0009; remaining skills are in Now.
- 2026-09-03 Drafted the first eval seed (`evals/bake-a-feature/`) — see Next; running is gated in early access, so it is unverified.
- 2026-09-03 Works-check pass: verified all 8 skills run — cross-skill calls resolve, `allowed-tools` complete, load path green, each skill behaviourally sane. Swept dust: trimmed over-declared `allowed-tools` on `code-review` and `comment-on-pr`, added a `gh` missing/unauthenticated guard to `comment-on-pr`, aligned the plugin blurb across `plugin.json` and `marketplace.json`.
- 2026-09-03 Enforcement widened: GitHub Actions (`.github/workflows/check.yml`) runs `check-manifest.sh` on push + PR — covers the fresh-clone gap in ADR-0008 server-side. `check-manifest.sh` also asserts every `boo:<name>` reference in a promoted `SKILL.md` resolves to a real promoted skill (catches a rename silently breaking a cross-skill call).
- 2026-09-03 Closed two open questions. `writing-for-agents` (the craft) stays separate from `.agents/writing-skills.md` (the checklist) — under ~5% overlap, clean division, mutual cross-refs. Manual `plugin.json` version bumps stay manual — a release script is deferred until releases are frequent (still v0.1.0).
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
