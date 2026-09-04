# 0011. Authoring a skill: hybrid skill + deterministic script

## Context

Adding a promoted skill is a fixed multi-file dance: create `skills/<bucket>/<name>/SKILL.md`, add the path to `plugin.json` `skills[]`, add a bullet to the root README and the bucket README, re-link, and pass `check-manifest.sh`. Done by hand it is easy to get half-right — the exact gap `check-manifest.sh` exists to catch.

Two parts of the job have different natures:

- **Judgment** — the name, the bucket, whether it is user- or model-invoked, the one-line description, and the body prose. These need the model, and for a good result an interview (`baking`) and the writing craft (`writing-for-agents`).
- **Determinism** — the file creation and the manifest/README edits. Same every time; no judgment; brittle when a model free-hands JSON and markdown insertion.

`writing-for-agents` already says prose is for judgment and deterministic dances belong in a script. So the question was not *skill or script* but *where the seam goes*.

## Decision

Split the work across a **skill** and a **script**, seam between judgment and determinism.

- **`skills/productivity/make-skill/`** (user-invoked) runs the interview, decides the four design values, then drafts the body with the `writing-for-agents` method. It never edits `plugin.json` or the READMEs itself.
- **`scripts/new-skill.sh`** takes `<bucket> <name> <user|model> "<description>"`, writes `SKILL.md` from a template (frontmatter + the mandatory `**Plain language.**` clause + a `TODO(make-skill)` body marker), inserts the skill into `plugin.json` (sorted) and both READMEs (structured edits in `python3`, not shell string-mangling), then self-verifies by running `link-skills.sh` and `check-manifest.sh`.
- **Promoted buckets only.** `private/` skills are rare and wired differently (bare link, no manifest); scaffold them by hand. Add private support to the script only if that turns out to hurt.

## Consequences

- The manifest edits are done the same way every time and are verified by the same `check-manifest.sh` the repo already trusts — the script proves its own output before returning.
- `make-skill` stays short: it carries no wiring instructions, only the interview and the draft. The wiring lives in one place.
- The script is the one repo-hardwired piece (it knows the bucket layout and the README shape). That is deliberate: `make-skill`'s prose stays portable per [0009-capability-language.md](./0009-capability-language.md); the harness-specific mechanics sit in the script it calls.
- The template always emits the plain-language clause because `check-manifest.sh` requires it on every promoted skill ([0006-plain-language-output.md](./0006-plain-language-output.md)), even skills whose output is not person-facing. If that enforcement is ever narrowed, the template follows.
- Reverting is `git revert` of the introducing commit: the skill, the script, and this ADR go together.
