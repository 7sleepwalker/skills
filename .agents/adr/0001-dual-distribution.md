# 0001. Dual distribution: symlinks locally, plugin for other machines

Amended by [0005-boo-namespace.md](./0005-boo-namespace.md): the local symlink is now one link to the repo root, not one per skill.

## Context

Skills in this repo need to reach two places: the machine they are written on, where the edit loop should be instant, and any other machine or person, where a managed install is what makes sense.

Claude Code offers both. `~/.claude/skills/<name>` is read on every session start, so a symlink into this repo means an edit is live in the next session with no install step. A plugin (`.claude-plugin/plugin.json` plus a marketplace manifest) is versioned and installed, so an edit only lands after an update.

## Decision

Ship both, and use exactly one per machine.

- **The authoring machine uses symlinks.** `scripts/link-skills.sh` links every skill dir into `~/.claude/skills`. `git pull` is the update mechanism.
- **Every other machine installs the plugin.** The repo is its own single-plugin marketplace.
- **Never both on one machine.** Each skill would appear twice, and the two copies would drift.

## Consequences

- The edit loop stays instant where the skills are written, which is the common case.
- `plugin.json`'s `skills[]` can drift from the filesystem, since nothing on the authoring machine reads it. `scripts/check-manifest.sh` exists to catch that, and must be run before pushing.
- The plugin path is untested by daily use. It gets verified explicitly at Phase 4 and after any change to the manifests.
