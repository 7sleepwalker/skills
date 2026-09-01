# Working in this repo

This repo holds my agent skills. It is not an application: the deliverable is prose that other agents follow.

## Layout

Skills live in bucket folders under `skills/`:

- `engineering/`: daily code work
- `productivity/`: daily non-code workflow
- `private/`: work-specific, **gitignored**, never referenced from a tracked file

`engineering/` and `productivity/` are the **promoted** buckets. A promoted skill must appear in all three of: the root `README.md`, its bucket `README.md`, and `.claude-plugin/plugin.json`'s `skills[]`. Anything under `private/` appears in none of them.

There is no `misc/`, `in-progress/`, or `deprecated/` bucket. A retired skill is deleted and noted in the `ROADMAP.md` Done log.

## Rules

- Skill authoring conventions, frontmatter, and the pre-commit checklist: [.agents/writing-skills.md](./.agents/writing-skills.md).
- User-invoked vs model-invoked, and how one skill invokes another: [.agents/invocation.md](./.agents/invocation.md).
- Decisions about how the repo works are recorded in [.agents/adr](./.agents/adr). Add a new ADR rather than relitigating one in conversation.
- `ROADMAP.md` is the live plan. Update it in the same commit as the work it describes.
- Nothing internal or employer-specific in tracked files: no internal hostnames, repo paths, or issue-tracker project keys. Those belong in `skills/private/`.

## Commands

| Command | When |
| --- | --- |
| `./scripts/check-manifest.sh` | after adding, renaming, or removing a skill; also runs automatically on `git push` (pre-push hook) and blocks the push if it fails |
| `./scripts/link-skills.sh` | after adding or renaming a skill, to (re)link every skill into `~/.claude/skills`; also enables the git hooks (`core.hooksPath`) |
| `./scripts/unlink-skills.sh` | to remove this repo's symlinks from `~/.claude/skills` and disable the git hooks (unsets `core.hooksPath` if it still points at ours) |
| `./scripts/list-skills.sh` | to see every skill with its bucket, invocation mode, and a short description |

This machine consumes the skills through symlinks, not through the plugin. Do not install the plugin here: every skill would appear twice. See [.agents/adr/0001-dual-distribution.md](./.agents/adr/0001-dual-distribution.md).

`check-manifest.sh` is enforced by a tracked `.githooks/pre-push` hook, turned on per machine by `link-skills.sh`. A fresh clone has no enforcement until that script runs once; bypass a single push in an emergency with `git push --no-verify`. See [.agents/adr/0008-pre-push-hook.md](./.agents/adr/0008-pre-push-hook.md).
