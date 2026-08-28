# 0005. The `boo:` namespace

Amends [0001-dual-distribution.md](./0001-dual-distribution.md). That decision stands; only the shape of the local symlink changes.

## Context

Skills from this repo were indistinguishable from every other skill in `~/.claude/skills`. The cost is not collision, it is **discovery**: with no shared prefix there is no way to find a skill by typing when its exact name has been forgotten.

Claude Code namespaces plugin skills as `plugin-name:skill-name`. Plain personal skills take their command name from the directory name, and a `:` there is undocumented and prone to silent failure. So the prefix has to come from a plugin.

A directory under `~/.claude/skills/` containing `.claude-plugin/plugin.json` auto-loads as a **skills-directory plugin** — no marketplace, no install step, and `SKILL.md` edits still take effect immediately. This repo already ships that manifest for the other-machine install path, so the namespace is reachable without changing anything about how the repo is laid out.

## Decision

Rename the plugin to `boo` and link the repo root into `~/.claude/skills` as a single symlink.

- `~/.claude/skills/boo -> <repo>`, replacing the one-symlink-per-skill scheme.
- Promoted skills are invoked as `boo:<skill-name>`, for both slash commands and the Skill tool. Cross-skill calls inside `SKILL.md` files carry the prefix explicitly rather than relying on the bare name resolving.
- **Private skills stay outside the namespace.** They are absent from `plugin.json`'s `skills[]`, so `scripts/link-skills.sh` gives them their own bare symlinks.
- The bucket folders, file layout, and manifests are otherwise untouched.

## Consequences

- Typing `/boo` lists everything this repo ships, which was the whole point.
- ADR-0001's edit loop survives intact: one symlink instead of seven, still no install step.
- Whether a bare `/baking` still resolves alongside `/boo:baking` is documented inconsistently upstream. Treat the prefix as the only supported name and write it everywhere.
- `scripts/unlink-skills.sh` had to learn to match a link pointing at the repo root exactly, not just into it — otherwise the revert path silently skipped the one link that matters.
- Reverting is `git revert` of the commit that introduced this, then `./scripts/link-skills.sh`.
