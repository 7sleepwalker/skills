# 0003. Two promoted buckets, plus a private overlay

## Context

Skills need grouping that survives growth. Upstream (`mattpocock/skills`) runs five buckets: `engineering/`, `productivity/`, `misc/`, `in-progress/`, `deprecated/`. Three of those exist to manage a public audience: signalling what is beta, what is unsupported, what is retired. This repo has an audience of one.

## Decision

Three buckets, two of them promoted.

- `skills/engineering/` (promoted): daily code work.
- `skills/productivity/` (promoted): non-code workflow.
- `skills/private/` (never promoted, gitignored): work-specific, see ADR 0002.

**Promoted** means the skill is listed in the root `README.md`, in its bucket `README.md`, and in `.claude-plugin/plugin.json`'s `skills[]`. Those three lists and the filesystem must agree; `scripts/check-manifest.sh` enforces it.

No `misc/`, `in-progress/`, or `deprecated/`. A retired skill is deleted, and the `ROADMAP.md` Done log records why. Git history is the archive.

## Consequences

- Every tracked skill is a real, supported skill. There is no half-shipped tier to explain.
- Deleting rather than deprecating means a retired skill vanishes from `~/.claude/skills` on the next `link-skills.sh` run, which is the intent.
- Adding a bucket later means updating `check-manifest.sh` and both manifests, so the cost of the decision is not zero. Prefer more skills in two buckets over more buckets.
