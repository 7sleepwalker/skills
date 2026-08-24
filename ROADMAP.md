# Roadmap

Live plan for this repo. Update it in the same commit as the work it describes.
Decisions that change *how the repo works* go in an ADR under [.agents/adr](./.agents/adr), not here.

## Now

- [ ] Phase 4: publish the repo to GitHub as public, verify the plugin install path on a second machine

## Next

- [ ] Fill in `docs/`-style usage notes only if a skill turns out to need more than its `SKILL.md`

## Later

- [ ] Phase 5: private overlay (`skills/private/`) for work-specific skills. Build one only when a real task demands it.
  - design-system migration skill
  - monorepo conventions (package manager, type-check, package layout)
  - issue-tracker flow via the atlassian MCP
- [ ] Adapt `tdd` (plus its `tests.md` / `mocking.md` companions)
- [ ] A `/new-skill` scaffolder, once there are ~10 skills and the boilerplate hurts

## Open questions

- Is `writing-for-agents` (portable technique) worth keeping separate from `.agents/writing-skills.md` (house rules), or should one absorb the other?
- Manual `plugin.json` version bumps: good enough, or worth a release script later?

## Done

- 2026-08-24 Phase 3: adapted `baking`, `bake-it`, `diagnosing-bugs`, `handoff`, `writing-for-agents`; added `CREDITS.md`, bucket READMEs, root README, plugin + marketplace manifests
- 2026-08-24 Phase 2: migrated `code-quality` into `skills/engineering/` (`Task` -> `Agent` tool rename); linked all six skills into `~/.claude/skills`
- 2026-08-24 Retired `review`: no frontmatter, and every section it covered is a strict subset of `code-quality`. Deleted rather than migrated
- 2026-08-24 Phase 1: conventions (`AGENTS.md`, `.agents/invocation.md`, `.agents/writing-skills.md`) and scripts (`link-skills.sh`, `unlink-skills.sh`, `list-skills.sh`, `check-manifest.sh`)
- 2026-08-24 Phase 0: repo scaffold, MIT license, gitignore, roadmap, ADRs 0001-0004
