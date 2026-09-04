# Changelog

All notable changes to this repo. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions track `.claude-plugin/plugin.json`. Day-by-day history of *how the repo works* lives in [ROADMAP.md](./ROADMAP.md)'s Done log; this file is the release-level summary.

## [0.2.0] — 2026-09-03

### Added

- `boo:make-skill` (productivity, user-invoked): author a new promoted skill end to end — interview its design with the `baking` method, scaffold and wire it, then draft the body with the `writing-for-agents` method.
- `scripts/new-skill.sh`: the deterministic half of `make-skill` — creates the `SKILL.md` from a template, wires `plugin.json` and both READMEs, then self-verifies with `link-skills.sh` and `check-manifest.sh`.
- `CHANGELOG.md` (this file).
- ADR-0011: authoring a skill is a hybrid skill + deterministic script.

## [0.1.0] — 2026-09-03

Initial public skill set: `bake-with-jira`, `code-review`, `comment-on-pr`, `diagnosing-bugs`, `bake-it`, `baking`, `handoff`, `writing-for-agents`, distributed as the `boo` plugin and as a Claude Code marketplace.
