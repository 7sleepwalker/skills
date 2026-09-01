# HTML report spec

Read this only when `--html` is passed. After writing the Markdown review, write the same report to `${TMPDIR:-/tmp}/code-review.html` (resolve `$TMPDIR` to an absolute path), then end your response with a clickable `file://` link. Temp location, never the repo. Overwrite each run.

The Markdown findings text is the source of truth — **never invent a finding not in the Markdown.**

## Requirements

- **Self-contained:** inline `<style>`, no external assets or scripts. Start with `<title>`; no `<html>`/`<head>`/`<body>` wrappers.
- **Theme-aware:** full light palette on bare `:root`; redefine tokens under both `@media (prefers-color-scheme: dark)` (guarded `:root:not([data-theme="light"])`) and `:root[data-theme="dark"]`; give `body` an explicit token background.
- **Same content + order as the Markdown:**
  - header (PR #/title/branch/base)
  - the **Review summary** — a prominent `<badge> <score>/10`, badge styled by band, reusing the severity token colours (8–10 green, 6–7 yellow, 4–5 orange, 1–3 red) — plus the per-area sentence list
  - verdict + the one-line summary
  - a stat row (candidates / dropped / surviving / severity counts)
  - the Scope-check block
  - each finding as a card: emoji severity badge + confidence + occurrences + a `suggestion` block styled as an addition + references
  - a "below the bar" section for sub-threshold correctness observations
  - a "what was checked" footer
- **Badges colour-coded:** 🟠 High visually distinct from 🔴 Critical; `❓ [q]` a neutral badge outside the severity scale.
