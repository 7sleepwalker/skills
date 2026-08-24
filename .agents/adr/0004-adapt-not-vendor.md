# 0004. Adapt upstream skills, do not vendor them

## Context

Several skills here start from `mattpocock/skills` (MIT), which is actively maintained and changes often. Three ways to take them: install his plugin alongside this repo, vendor his files and pull updates, or read the technique and write our own.

Installing his plugin is read-only: no customization, and it collides with skills of the same name here. Vendoring means every local edit becomes a merge conflict on the next sync, and his skills assume repo setup (`/setup-matt-pocock-skills`, a `CONTEXT.md`, a configured issue tracker) this repo has not adopted.

## Decision

Read the upstream skill for the technique, then write our own version from scratch: our voice, our defaults, no upstream prerequisites. Nothing is tracked against upstream, and there is no sync.

- Every adapted skill gets a row in `CREDITS.md` and an attribution footer naming `mattpocock/skills` and its MIT license.
- Renaming to fit this repo is expected, not a deviation: upstream `grilling` is `baking` here, `grill-me` is `bake-it`.

## Consequences

- Upstream improvements do not arrive automatically. Re-reading his repo occasionally is a deliberate task, not a `git pull`.
- Each adapted skill costs real writing time up front, which is the price of them fitting this setup.
- The MIT attribution obligation is discharged through `CREDITS.md` plus the per-skill footer. Both must be kept accurate.
