# 0008. Enforce check-manifest with a pre-push hook

## Context

`scripts/check-manifest.sh` was run by discipline only — the docs said "before every push", but nothing made it happen. A push with a broken manifest, a skill missing from a README, or a gutted plain-language clause (ADR-0006) went through unnoticed. This machine has no CI, so the check had no teeth.

A stock `.git/hooks/pre-push` would fix it locally but is **not tracked** by git: it does not travel to a fresh clone, and a second machine (ADR-0001) would silently have no enforcement.

## Decision

Ship a tracked `.githooks/pre-push` that runs `check-manifest.sh` and blocks the push on failure. Enable it per machine by pointing `core.hooksPath` at `.githooks`, which `scripts/link-skills.sh` now does as part of the same per-machine setup that links the skills.

- The hook lives in the repo, so it is version-controlled and reviewed like everything else.
- `link-skills.sh` sets `core.hooksPath .githooks` (guarded to run only in a git clone), so the existing "set up this machine" step also turns on enforcement — no separate install.
- The hook simply `exec`s `check-manifest.sh`; its exit code is the push's gate.

## Consequences

- A push that fails the manifest check is refused. The plain-language check, the README/manifest agreement, and the well-formedness checks are now enforced, not just documented.
- `core.hooksPath` replaces the whole `.git/hooks` directory. This repo used no other hooks, so nothing is lost; a contributor who adds one must put it in `.githooks`.
- A fresh clone has no enforcement until `link-skills.sh` runs once — acceptable, since that script is already the required first step on a new machine.
- Emergency escape is the standard `git push --no-verify`. Use it knowingly; the next push with the fix restores a clean state.
- Reverting is `git config --unset core.hooksPath` plus `git revert` of the introducing commit.
- Update (2026-09-03): GitHub Actions (`.github/workflows/check.yml`) now runs `check-manifest.sh` on every push and PR, so the fresh-clone gap above is covered server-side. The local hook stays as the fast pre-push signal; CI is the backstop that does not depend on `link-skills.sh` having run.
