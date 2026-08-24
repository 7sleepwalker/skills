# 0002. Public repo, gitignored private overlay

## Context

The useful skills split in two. Most are generic engineering and productivity workflows worth sharing. A minority encode work specifics: internal repo names and paths, internal hostnames, issue-tracker project keys, private design-system conventions. Those cannot go in a public repo, but they need the same authoring, linking, and review workflow as the rest.

## Decision

One public repo. `skills/private/` is gitignored and holds the work-specific skills.

- Tracked buckets (`engineering/`, `productivity/`) contain nothing internal: no internal hostnames, no repo paths, no project keys, no employer-specific product names.
- `skills/private/` is ignored by git and may hold its own independent git repo pointing at an internal remote. The outer repo never sees it.
- `scripts/link-skills.sh` links private skills alongside public ones, so day to day there is no difference in how they are used.
- `scripts/check-manifest.sh` fails if a private skill is referenced from any tracked file.

## Consequences

- The public repo stays shareable without a sanitizing pass before every push.
- A private skill is invisible to the plugin. Other machines get it only through whatever internal remote `skills/private/` is pushed to, if any.
- A generic skill that grows work-specific detail has to be split rather than quietly kept, and the leak check is what forces the issue.
