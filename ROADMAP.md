# Roadmap

Live plan for this repo. Update it in the same commit as the work it describes.
Decisions that change *how the repo works* go in an ADR under [.agents/adr](./.agents/adr), not here.

## Now

- [ ] Phase 4: publish the repo to GitHub as public, verify the plugin install path on a second machine

## Next

- [ ] Fill in `docs/`-style usage notes only if a skill turns out to need more than its `SKILL.md`
- [ ] Add skill evals once `claude plugin eval` leaves early access (not enabled in-session yet). Schema captured: cases at `skills/<bucket>/<name>/evals/<case>/prompt.md` (frontmatter `name`, `tags`, `runs`, `max_turns`, `allowed_tools`, `model`) + `evals/<case>/graders/<name>.md` (`type:` regex | tool_used | tool_order | file_exists | llm | baseline; `target:` last_message | trace | files). Run `claude plugin eval . --allow-tools Bash Write`; results at `<eval-dir>/results/<ts>/aggregate-result.json` + `report.html`, exit 0 = all cases ≥ `--threshold` (default 1.0). Seed `code-quality` + `baking` first. Source: Anthropic skill-creator.

## Open questions

- Is `writing-for-agents` (portable technique) worth keeping separate from `.agents/writing-skills.md` (house rules), or should one absorb the other?
- Manual `plugin.json` version bumps: good enough, or worth a release script later?

## Done

- 2026-08-29 Learned from `awesome-agent-skills`: `baking` gained lettered options + per-question "not sure" (no accept-all); `code-quality` gained blast radius + git-blame regression context (adapted from trailofbits/skills `differential-review`). Evals parked in Next.
- 2026-08-28 Namespaced every promoted skill under `boo:` via a skills-directory plugin (ADR-0005); `link-skills.sh` now makes one link to the repo root, private skills keep bare links
- 2026-08-28 Merged `caveman-review` severity prefixes and the `mattpocock/code-review` Fowler smell baseline into `code-quality`; added `smells.md`, a `q` category, and the two-axis rule

- 2026-08-25 Added `bake-with-jira`: pick a Jira ticket assigned to me, recon the repo, run the `baking` interview, hand off to plan mode
- 2026-08-24 Phase 3: adapted `baking`, `bake-it`, `diagnosing-bugs`, `handoff`, `writing-for-agents`; added `CREDITS.md`, bucket READMEs, root README, plugin + marketplace manifests
- 2026-08-24 Phase 2: migrated `code-quality` into `skills/engineering/` (`Task` -> `Agent` tool rename); linked all six skills into `~/.claude/skills`
- 2026-08-24 Retired `review`: no frontmatter, and every section it covered is a strict subset of `code-quality`. Deleted rather than migrated
- 2026-08-24 Phase 1: conventions (`AGENTS.md`, `.agents/invocation.md`, `.agents/writing-skills.md`) and scripts (`link-skills.sh`, `unlink-skills.sh`, `list-skills.sh`, `check-manifest.sh`)
- 2026-08-24 Phase 0: repo scaffold, MIT license, gitignore, roadmap, ADRs 0001-0004
