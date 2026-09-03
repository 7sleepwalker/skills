# 0010. Cross-agent distribution via ~/.agents/skills

## Context

The skill bodies are agent-agnostic now ([0009-capability-language.md](./0009-capability-language.md)) — any agent can *follow* the prose. But nothing made a non-Claude agent *load* them. On this machine the skills reach Claude Code through `~/.claude/skills` (the `boo` plugin symlink, [0001-dual-distribution.md](./0001-dual-distribution.md)); no other agent looks there.

Two delivery shapes were on the table:

- **Replication** (caveman's route): copy each `SKILL.md` into every agent's own directory (`.cursor/`, `.windsurf/`, `.codex/`). Native discovery per agent, but N copies to keep in sync. caveman gets away with it because its content is a frozen one-pager; our bodies change, so copies would rot.
- **One generic dir** (mattpocock's route): symlink every skill into `~/.agents/skills`, the cross-agent skills directory. One source of truth, no copies.

Agent Skills is an open standard, not a Claude-only idea. Anthropic published the SKILL.md spec in December 2025; OpenAI (Codex CLI, ChatGPT), Google (Gemini CLI), Cursor, GitHub Copilot, Windsurf, and Cline adopted it. The ecosystem is converging on `.agents/skills/` and `~/.agents/skills/` as the shared discovery path — Windsurf scans both, and can optionally also read `~/.claude/skills`. mattpocock's `link-skills.sh` links into `~/.claude/skills` and `~/.agents/skills` for exactly this reason. So the generic dir is the standard route, not a bet on one tool.

## Decision

`link-skills.sh` also links every skill (promoted + private) into `~/.agents/skills`, one bare symlink per skill directory. `unlink-skills.sh` removes them symmetrically.

- **Symlinks, not copies.** An edit here is live everywhere at once; nothing to re-sync, nothing to rot. This keeps the one-source-of-truth rule the repo already holds.
- **Bare links, no namespace.** The `boo:` namespace is a Claude Code plugin concept ([0005-boo-namespace.md](./0005-boo-namespace.md)); outside it, agents discover skills by directory name. So `~/.agents/skills/<name>`, not `~/.agents/skills/boo/<name>`.
- **Override with `AGENTS_SKILLS_DIR`**, the way `CLAUDE_SKILLS_DIR` overrides the Claude target.
- `AGENTS.md` stays what it is — the repo's working conventions (mirrors the role of `CLAUDE.md`), not a skill loader. Distribution lives in the link scripts, not in `AGENTS.md`.

## Consequences

- Any agent that reads `~/.agents/skills` picks up the same skills the Claude plugin ships, with no extra step beyond the `link-skills.sh` the machine already runs.
- **The standard is real, but the directory spec is not yet frozen.** The single `AGENTS.md` *file* is stable and widely adopted; the `.agents/` *directory* spec (AGENTS-1) is still Work-In-Progress, so the `~/.agents/skills` location could shift before it settles. If it moves, or a specific agent discovers skills elsewhere (a project-local `.cursor/rules`, its own config), add that path to `link-skills.sh` — the pattern is now in place to extend, not re-invent.
- **Portability holds for the plain-Markdown core.** A skill built on `name` + `description` + Markdown body (ADR-0009) travels to any harness that implements the standard. Claude-only frontmatter (`disable-model-invocation`, `allowed-tools`) is ignored by the others — additive, not breaking.
- Private skills go into `~/.agents/skills` too (they already get bare links in `~/.claude/skills`). They are the user's own; whether every private skill is fully agent-agnostic is the user's call, not the script's.
- A third distribution channel now exists (Claude plugin, Claude bare links, generic dir). `check-manifest.sh` does not police `~/.agents/skills` — it is a link target, not tracked content.
- Reverting is `git revert` of the introducing commit; `unlink-skills.sh` clears the links a machine already made.
