---
name: code-review
description: "PR-focused review against the repo's own standards — quality, overcomplication, logic-bug risk, and scope vs the PR + linked ticket. Parallel agents; optional HTML report via --html. To post findings as inline PR comments, use boo:comment-on-pr. Args: [PR#|url|path|--staged|--all] [TICKET] [--html]"
argument-hint: "[PR#|url] [--html]"
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git status:*), Bash(git ls-files:*), Bash(git log:*), Bash(git blame:*), Bash(git rev-parse:*), Bash(git symbolic-ref:*), Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr list:*), Agent, mcp__atlassian__getJiraIssue, mcp__atlassian__getAccessibleAtlassianResources, mcp__atlassian__search, Write
---

# Code Quality Review (PR-focused)

Raise the engineering bar of whatever repo you're run in, and catch what the PR introduces: code quality, overcomplication (solutions heavier than the problem), logic-bug risk in the change, and whether the diff matches the **PR description + linked ticket**. Defaults to the current branch's open PR.

Guardrails that never change:
- Only judge **NEW / changed code** in the diff. Never flag pre-existing code the PR didn't touch.
- **Preserve intended behavior.** Report correctness risks; never silently rewrite what the code is meant to do.
- **High-signal only.** A senior engineer on THIS repo should nod at every surviving finding.
- **Plain language.** Write anything a person reads — questions, findings, summaries, reports — for a non-native English speaker: short sentences, one idea each, common words, no idioms or phrasal verbs. Keep technical terms and proper names exact (`null-check`, `race`) and never simplify code. Clear over clever.

## Arguments

Parse `$ARGUMENTS`, order-independent:

- **PR selector** (default: the current branch's open PR): a bare number (`5616`) or PR URL → that PR; nothing → auto-detect (Step 1).
- **Local override scopes** (pre-PR review, no PR yet): `--staged` → `git diff --staged`; `--all` → full diff vs the default branch; a `path` → only that path.
- **Ticket** (optional): a `[A-Z]+-\d+` token or issue-tracker URL. If absent, auto-detect from the branch name and PR title/body.
- **`--html`** → also write an HTML report (Step 4, item 5). Without it, Markdown only.

Posting findings to the PR is a separate, interactive skill: `boo:comment-on-pr`. This skill only reviews.

## Step 0 — Discover this repo's standards

**The repo you're in is the authority.** There are no hardcoded framework rules; never impose another project's conventions. Find the rule sources it ships and cite them by path in findings: `CLAUDE.md`, `AGENTS.md`, `.agent-rules/**`, `.cursor/rules/**`, `.github/copilot-instructions.md`, `CONTRIBUTING.md`, `.editorconfig`, `docs/**` style guides, plus config that encodes conventions (`eslint`, `tsconfig`, `package.json` scripts, `pyproject.toml`). Note the ecosystem (language, framework, package manager, test runner, design system) so agents judge against the right idioms.

Where the repo is silent, [smells.md](smells.md) carries the review — say the review used it plus universal defaults.

## Step 1 — Resolve the PR + diff + ticket

1. **Select the PR:** explicit number/URL → use it. Else the current branch's: `gh pr view --json number,title,body,baseRefName,headRefName,url,state,files` (`GH_HOST` targets this repo's host, Enterprise included). No PR / `gh` unavailable / a local scope passed → local diff (the scope, else `--all` vs the base from `git symbolic-ref --short refs/remotes/origin/HEAD` stripped of `origin/`, fallback `main`/`master`); note "No PR — reviewing branch vs `<base>`" (the scope check runs off local diff only).
2. **Changed files:** for a PR, `gh pr diff <n> --name-only` (diff is `baseRefName...headRefName`); for a local scope, the matching `git diff --name-only`. Skip formatting/generated output.
3. **Ticket:** match `[A-Z]+-\d+` in the ticket arg → branch → PR title/body. If a key exists and the atlassian MCP is available, fetch ONCE — `cloudId` from the URL host, else `getAccessibleAtlassianResources` → first site; then `getJiraIssue({ cloudId, issueIdOrKey, fields: ['summary','description','issuetype','status'] })`. A one-time permission prompt is expected. On any failure → the scope check runs off PR title/body alone (note "ticket unavailable").
4. **Pre-flight:** confirm the base ref resolves (`git rev-parse <base>`) and the diff is **non-empty**. If not, stop and say which — do not spawn agents against nothing. Then size the diff (`gh pr diff <n> --stat` for a PR, the matching `git diff --stat` for a local scope). If it's large (heuristic: ~1500+ changed lines or ~40+ files), **don't stop** — tell each agent to rank changed files by churn (lines changed) and review the top files thoroughly, listing the rest as "below churn cut — not deeply reviewed (`<n>` files)". Surface this in the output (Step 4) so a skimmed pass is never silent.

Do NOT read the changed files yourself — hand that to the agents so the passes run in parallel.

## Step 2 — Fan out the review passes (parallel)

Read [smells.md](smells.md) yourself first; sub-agents can't path to this skill's directory, so paste it in full into Agent Q2's brief.

Launch these agents **concurrently** (`Agent` tool, one message). Give each: the changed-files list, the base/head diff command, and the Step 0 rule-source paths — with the instruction to **load those rule files itself** (authority, not memory) and judge only what this repo mandates. Each returns findings as `{severity, file:line(s), impact + cited rule path:line (or "no repo rule; universal principle"), suggested fix, confidence 0-100}`.

- **Q1 — Standards & conventions:** names, file/module layout, layer boundaries, dependency direction, public-API surface, and any mandated data/API/state/UI pattern (required client, typed hooks, component library, forbidden raw libs) — as the repo's rules define them. Universal fallback when silent: consistency with sibling code, no circular deps, no cross-layer leaks, minimal export surface.
- **Q2 — Reuse/simplification + testing** (paste `smells.md` here): pattern repeated 3+ → extract; monolith (>~200-300 lines) or nesting >3 → split; check the repo's own utils/libs before flagging reinvention; dead code, redundant state, nested ternaries. Judge the diff against the pasted smell catalogue under both its rules. Testing: follow the repo's conventions; missing tests for new/changed critical logic or shared utilities is a strong finding.
- **R — Correctness & complexity** (diff + adjacent context only): **overcomplication** — needless abstraction, extra state/indirection, speculative generality; report the simpler shape. **Logic-bug risk** — off-by-one, inverted/incomplete conditions, wrong operator, missing null/empty handling, unhandled rejection / missing `await`, broken invariants, stale-closure / dep-array bugs, races. Only correctness the CHANGE introduces, not typecheck-catchable errors. **Blast radius:** for each changed exported symbol, count its callers with Grep (LSP if available) — a bug in something called from many sites is worse than the same bug in a leaf; feed the count into severity. **git blame:** run it on changed lines to separate a fresh change from a long-standing line touched incidentally, and to flag a change that reverts a previously-fixed bug (regression).
- **S — PR scope** (always, for a PR): compare PR title + body (and the ticket if fetched) to the diff. Return **Asked / Changed / Out-of-scope extras / Possible gaps**. Advisory — no severity, exempt from the confidence bar. Skip only in local-fallback mode with no ticket.

**Degrade path:** if the `Agent` tool is unavailable, run Q1 → Q2 → R → S inline yourself. Same rules, same output.

## Step 3 — Merge, severity, confidence bar

- **Severity rubric** (a repo-specific rubric, if shipped, overrides it):
  - **🔴 [Critical]** — security holes, data loss/corruption, crashes, broken core behavior, circular deps, missing tests for critical logic.
  - **🟠 [High]** — likely bug, violation of a rule the repo mandates, significant duplication, wrong/forbidden API or UI pattern.
  - **🟡 [Medium]** — edge-case correctness risk, real maintainability problem, moderate overcomplication.
  - **🔵 [Low]** — minor readability/simplification, small local cleanup.
  - **❓ [q]** — a genuine question about intent you can't resolve without the author. No severity, not ranked, **exempt from the confidence bar**. Use it instead of ever hedging.
  - **[Ignore]** — never report: formatting/lint/import-order/style, and anything a typechecker/linter/compiler catches.
- Logic-bug and overcomplication findings share the **same ranked list** as quality findings.
- Dedupe **one-pattern-one-finding** (list occurrences, don't repeat per line).
- Rank: Security > Data integrity > Correctness > Performance > Simplicity > Maintainability > Readability > Style. Blast radius (from Agent R) is a tie-breaker within a tier: the more callers a finding reaches, the higher it sits.
- **Confidence bar:** judge each finding's confidence that it's real, in-scope, not pre-existing, not intentional. Score it 0-100 as a coarse band, not a precise metric (75 vs 85 is a judgment call, not a measurement). **Drop anything below 80.** Scope check and `❓ [q]` are exempt.
- **Overall score (0-10, quality axis only) + badge.** From the *surviving* Q1/Q2/R findings: the worst finding sets the band, count + blast radius place within it. `❓ [q]` and the Scope axis never move it.
  - `10` — no surviving findings → 🟢
  - `8–9` — only 🔵 Low → 🟢
  - `6–7` — 🟡 Medium present, no High/Critical → 🟡
  - `4–5` — 🟠 High present, no Critical → 🟠
  - `1–3` — any 🔴 Critical → 🔴
- **Per-area buckets:** group the changed files by top-level module/directory and attach each surviving finding to its area — one sentence per area for the summary (its worst issue, or "clean").
- **Two axes, never merged.** The ranked findings (Q1/Q2/R) and the Scope check (S) stay separate — never rank one against the other, never let a clean scope check soften a 🔴 or vice versa. A PR can pass one axis and fail the other.

## Step 4 — Output

Write every field terse and concrete: exact line numbers, exact symbols in backticks, a concrete fix (not "consider refactoring"), and the *why* when the fix isn't self-evident. Drop "I noticed that…", "it seems like…", "you might want to…", restating what the line does, and hedging (raise a `❓ [q]` instead). State the overall verdict once, at the top. **Exception:** 🔴 security findings get a full explanation and a reference; architectural disagreements get the rationale spelled out.

0. **Review summary** — lead with this at-a-glance block (the overall verdict, stated once):
   ```
   ## Review summary — 🟢 9/10

   *Quality axis only; scope tracked separately below.*

   - **`src/auth/`** — <one sentence: worst issue in this area, or "clean">
   - **`src/api/`** — <one sentence>
   ```
   Headline is `<badge> <score>/10` from the Step 3 rubric. One sentence per module/dir touched, terse, same voice as findings — no hedging.

1. **Scope check** — then this non-blocking advisory:
   ```
   ## Scope check — PR #<n>: <PR title>  ·  <KEY>: <ticket title>

   - **Asked:** …
   - **Changed:** …
   - **Out-of-scope extras:** … (or "none")
   - **Possible gaps:** … (or "none")
   ```

2. **Findings** — most severe first:
   ```
   ## 🔴 [Critical] Short title

   **Impact:** <why — cite the repo rule path:line, or the concrete failure>

   **Occurrences:**
   - `path/to/file.ext:line`

   **Fix:**
   ​```suggestion
   <corrected code>
   ​```

   **References:** <rule path(s), "smells.md — possible <smell>", or "universal principle — no repo rule">
   ```

3. **Close with one summary line** — per-axis counts and the worst issue **within each axis**, no cross-axis winner:
   ```
   2 scope gaps · 5 findings, worst 🔴 Critical
   ```

4. If nothing survives: "No qualifying findings. Checked naming/structure, conventions/API, reuse/simplification, smell baseline, testing, overcomplication, logic-bug risk, and PR scope." Say whether repo rules, the smell baseline, or universal defaults were used.

5. **HTML report** (only with `--html`) — when the flag is passed, read [html-report.md](html-report.md) and follow it: write the same content and order as the Markdown to `${TMPDIR:-/tmp}/code-review.html`, then end your response with a clickable `file://` link. Without `--html`, skip this step entirely.

To post these findings to the PR, the user runs `boo:comment-on-pr`, which gates each comment. This skill reports; it never edits.

---
Severity prefixes and the terse finding style are adapted from [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) (skills are MIT). The smell baseline and the two-axis rule are adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT). Blast radius and git-blame regression context are adapted from [trailofbits/skills](https://github.com/trailofbits/skills) `differential-review` (CC-BY-SA-4.0) — technique only, rewritten here.
