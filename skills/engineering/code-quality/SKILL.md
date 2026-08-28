---
name: code-quality
description: PR-focused code review against the current repo's own standards — quality (naming/structure, module/API conventions, reuse/simplification, testing), overcomplication, and logic-bug risk, plus scope match vs the PR description and any linked issue ticket. Defaults to the current branch's open PR (diff base...head), discovers the repo's rules at runtime, falls back to a Fowler smell baseline where the repo is silent, fans the passes out across parallel agents, reports prefixed findings + a clickable HTML report, optionally posts back to the PR with --post, and applies safe fixes with --fix. Args: [PR#|url|path|--staged|--all] [TICKET] [--post] [--fix]
argument-hint: "[PR#|url] [--post] [--fix]"
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git status:*), Bash(git ls-files:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git symbolic-ref:*), Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr list:*), Bash(gh pr comment:*), Agent, mcp__atlassian__getJiraIssue, mcp__atlassian__getAccessibleAtlassianResources, mcp__atlassian__search, Edit, Write
---

# Code Quality Review (PR-focused)

Personal, repo-agnostic PR reviewer. Your job is to **raise the engineering bar of whatever repo you're run in** AND catch problems the PR introduces. In one run you check: code quality + adherence to *this repo's* standards, overcomplication (solutions heavier than the problem needs), logic-bug risk (correctness of the change), and whether the diff matches what the **PR description + linked ticket** asked for.

There are no hardcoded framework/library rules here. **The authority is the repo you're in**, discovered at runtime (Step 0). Never impose conventions from another project. Where the repo is silent, [smells.md](smells.md) is the fallback — read it in Step 2, and note its two binding rules: the repo always overrides it, and every smell in it is a judgement call rather than a violation.

Guardrails that never change:
- Only judge **NEW / changed code** in the PR diff. Never flag pre-existing code the PR didn't touch.
- **Preserve intended behavior.** You report correctness risks; you do not silently rewrite what the code is meant to do.
- **High-signal only.** Prefer explicit, readable code over clever brevity; a senior engineer on THIS repo should nod at every surviving finding.

## Arguments

Parse `$ARGUMENTS` (order-independent; classify each token):

- **PR selector** (default: the current branch's open PR):
  - a bare number (`5616`) or a PR URL → that PR.
  - nothing → auto-detect the open PR for the checked-out branch (Step 1).
- **Local override scopes** (secondary — use for pre-PR review when there's no PR yet):
  - `--staged` → `git diff --staged --name-only`.
  - `--all` → full diff vs the default branch.
  - a `path` (file or dir) → only that path.
- **Issue ticket** (optional): a token matching `[A-Z]+-\d+` or an issue-tracker URL. If none is passed, auto-detect from the branch name AND the PR title/body.
- **`--post`** → after the local report, post the review back to the PR as a comment (Step 4). Off by default.
- **`--fix`** → after reporting, apply the safe fixes to the working tree (see Step 5). Without it, report only.

## Step 0 — Discover this repo's standards (orchestrator, cheap)

Find the rule sources the repo ships and treat them as authority. Look for (whichever exist): `CLAUDE.md`, `AGENTS.md`, `.agent-rules/**`, `.cursor/rules/**`, `.github/copilot-instructions.md`, `CONTRIBUTING.md`, `.editorconfig`, `docs/**` style guides, plus config that encodes conventions (`eslint`, `tsconfig`, `package.json` scripts, `pyproject.toml`, etc.). Record the paths — agents will load the relevant ones themselves and **cite them by path** in findings.

Also note the ecosystem (language, framework, package manager, test runner, design system if any) from the manifests so agents judge against the right idioms. If the repo ships **no** written standards, the smell baseline carries the review — say the review used defaults plus that baseline.

## Step 1 — Resolve the PR + diff + ticket (orchestrator, cheap)

1. **Select the PR:**
   - Explicit number/URL arg → use it.
   - Else the current branch's PR: `gh pr view --json number,title,body,baseRefName,headRefName,url,state,files`. (`GH_HOST` targets this repo's host — GitHub Enterprise included.)
   - **No PR / `gh` unavailable / a local override scope was passed** → fall back to a local diff (override scope, else `--all` vs the default base resolved via `git symbolic-ref --short refs/remotes/origin/HEAD` → strip `origin/`, fallback `main`/`master`). Note "No PR found — reviewing branch vs `<base>`." `--post` is a no-op in this mode; say so.
2. **Changed-files list:** for a PR, `gh pr diff <n> --name-only` (or the `files` from step 1) — the diff is `baseRefName...headRefName`. For a local scope, the matching `git diff --name-only`. Skip pure formatting/generated output.
3. **Ticket key:** match `[A-Z]+-\d+` in the ticket arg → branch name → PR title/body. If a key exists and the atlassian MCP is available, fetch ONCE:
   - `cloudId`: from the URL host if a URL was passed; otherwise `mcp__atlassian__getAccessibleAtlassianResources` → first site.
   - `mcp__atlassian__getJiraIssue({ cloudId, issueIdOrKey: <KEY>, fields: ['summary','description','issuetype','status'] })`
   - Tools may not be allowlisted; a one-time permission prompt is expected. On failure/denied/not-found/unavailable → degrade: the scope check still runs off the **PR title/body** alone (note "ticket unavailable").
4. **Pre-flight before spawning anything.** Confirm the base ref resolves (`git rev-parse <base>`) and that the diff is **non-empty**. If the ref won't resolve or the diff is empty, stop and say which — do not launch Step 2 against nothing.

Do NOT read the changed files yourself here — hand that to the agents in Step 2 so the passes run in parallel.

## Step 2 — Fan out the review passes (parallel)

First read [smells.md](smells.md) yourself. Sub-agents cannot reliably path to this skill's own directory, so its contents must be **pasted in full** into Agent Q2's brief.

Launch the following agents **concurrently** via the `Agent` tool (one message, multiple tool calls). Give each: the changed-files list + the base/head diff command, the rule-source paths from Step 0, and instructions to **load those rule files itself** (authority, not memory) and judge only against what this repo actually mandates. Each returns a structured finding list: `{severity, file:line(s), impact + cited rule path:line (or "repo has no rule; universal principle"), suggested fix, self-confidence 0-100}`.

- **Agent Q1 — Standards & conventions**
  - Naming + structure: judge names, file/module layout, module/layer boundaries, dependency direction, and public-API surface **as the repo's own rules define them**; cite the exact rule file. Universal fallback when the repo is silent: consistency with sibling code, no circular deps, no cross-layer leaks, minimal export surface.
  - API / data / UI patterns: if the repo mandates specific data-fetching, API, state, or design-system/UI patterns (e.g. a required client, typed hooks, a component library, forbidden raw libraries), enforce those and cite the rule. Flag new code that ignores a mandated pattern or reaches for a forbidden one.

- **Agent Q2 — Reuse/simplification + testing** (paste `smells.md` in full into this brief):
  - Reuse + simplification: same pattern repeated 3+ → extract; monolith (>~200-300 lines) or nesting >3 → split/flatten; before flagging reinvention, check the repo's own shared utils/components/libs and the std libs already in the stack; dead code / redundant state; no nested ternaries.
  - Smell baseline: judge the diff against the pasted catalogue, honouring both of its rules — the repo overrides it, and every hit is phrased as a possibility ("possible Feature Envy"), never as a violation.
  - Testing: follow the repo's testing conventions (runner, helpers, mocking approach, where tests live); missing tests for new/changed critical logic or shared utilities is a strong finding. Cite the repo's testing guide when one exists.

- **Agent R — Correctness & complexity** (bounded to the diff + immediately-adjacent context):
  - **Overcomplication:** solution heavier than the problem — needless abstraction, extra state/indirection, speculative generality, a simpler equivalent that preserves behavior. Report the simpler shape.
  - **Logic-bug risk:** off-by-one, inverted/incomplete conditions, wrong operator (`<` vs `<=`), missing null/undefined/empty handling, unhandled promise rejection / missing `await`, broken invariants, stale-closure / dependency-array bugs, state races. Only correctness the CHANGE introduces — not a general audit, not typecheck-catchable errors.

- **Agent S — PR scope** (always when reviewing a PR): compare the **PR title + body** (and the Jira ticket `summary`/`description` if fetched) to the diff. Return an advisory summary — **Asked** (what the PR + ticket want), **Changed** (what the diff does), **Out-of-scope extras** (changes unrelated to the stated intent), **Possible gaps** (asks not addressed). Informational — **no severity**, not subject to the confidence bar. Skip only in local-fallback mode with no ticket.

**Degrade path:** if the `Agent` tool (sub-agent dispatch) is unavailable in this CLI, run Q1 → Q2 → R → S inline in sequence yourself. Same rules, same output shape, just no parallelism.

## Step 3 — Merge, severity, confidence bar

Collect every agent's findings, then:

- Assign severity with this self-contained rubric (a repo-specific rubric, if the repo ships one, overrides it):
  - **🔴 [Critical]** — security holes, data loss/corruption, crashes, broken core behavior, circular deps, missing tests for critical logic.
  - **🟠 [High]** — likely bug, or violation of a rule the repo explicitly mandates, significant duplication, wrong/forbidden API or UI pattern per repo rules.
  - **🟡 [Medium]** — correctness risk in edge cases, real maintainability problem, moderate overcomplication.
  - **🔵 [Low]** — minor readability/simplification (e.g. nested ternary), small local cleanup.
  - **❓ [q]** — a genuine question about intent, where you cannot tell whether the code is wrong without the author's answer. No severity, not ranked, **exempt from the confidence bar**. This category exists so you never hedge: anything you'd have written as "this might be wrong, perhaps consider…" becomes a direct question instead.
  - **[Ignore]** — do NOT report: formatting/lint/import-order/style and anything a typechecker/linter/compiler would catch — CI + pre-commit handle these.
- Logic-bug and overcomplication findings live in the **same ranked list** as quality findings — correctness is not a separate tier.
- Dedupe **one-pattern-one-finding** (list occurrences, don't repeat per line).
- Rank by priority: Security > Data integrity > Correctness/logic > Performance > Code simplicity > Maintainability > Readability > Style.
- **Confidence bar:** score each finding 0-100 that it's a real, in-scope violation/risk (not a nitpick, not pre-existing, not intentional). **Drop anything below 80.** (The Scope check and `❓ [q]` items are exempt — they always show.)
- **Two axes, never merged.** The ranked findings list (Q1/Q2/R) and the Scope check (S) are separate axes. Do not merge them, do not rank one against the other, and do not let a clean scope check soften a 🔴 finding or vice versa. A PR can pass one axis and fail the other; that is the point of keeping them apart.

## Step 4 — Output

**How to write a finding.** Terse and concrete, in every field:
- **Drop:** "I noticed that…", "It seems like…", "You might want to consider…", "This is just a suggestion but…", restating what the line already does, and hedging words (perhaps / maybe / I think — raise a `❓ [q]` instead).
- **Keep:** exact line numbers, exact symbol names in backticks, a concrete fix rather than "consider refactoring", and the *why* whenever the fix isn't self-evident.
- **Say the overall verdict once**, at the top. Never repeat "great work, but…" per finding.
- **Relax terseness for two cases:** 🔴 security findings get a full explanation and a reference — a one-liner is not enough for a CVE-class problem; and architectural disagreements get the rationale spelled out. Resume terse afterwards.

1. **Scope check** — lead with a non-blocking advisory (cite the PR, and the ticket when fetched):
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

   **Impact:** <why it matters — cite the repo rule path:line, or the concrete failure it causes>

   **Occurrences:**
   - `path/to/file.ext:line`

   **Fix:**
   ​```suggestion
   <corrected code>
   ​```

   **References:** <rule file path(s), "smells.md — possible <smell>", or "universal principle — repo has no rule">
   ```

3. **Close with one summary line** — per-axis counts and the worst issue **within each axis**. Never pick a cross-axis winner:
   ```
   2 scope gaps · 5 findings, worst 🔴 Critical
   ```

4. If nothing survives: "No qualifying findings. Checked naming/structure, conventions/API, reuse/simplification, smell baseline, testing, overcomplication, logic-bug risk, and PR scope." Say whether repo rules, the smell baseline, or universal defaults were used.

5. **HTML report** (always) — after printing the Markdown, `Write` the same report to `${TMPDIR:-/tmp}/code-quality-review.html` (resolve `$TMPDIR` to an absolute path), then end your response with a clickable Markdown link to its `file://` path (e.g. `[Open review report](file:///abs/path/code-quality-review.html)`). Write to temp, NOT into the repo, so the review never pollutes the working tree. Requirements:
   - Single self-contained file: inline `<style>`, no external assets/CDNs/scripts. Start with a `<title>`; no `<html>`/`<head>`/`<body>` wrappers.
   - Theme-aware: define the full light palette on bare `:root`; redefine tokens under both `@media (prefers-color-scheme: dark)` (guarded `:root:not([data-theme="light"])`) and `:root[data-theme="dark"]`. Give `body` an explicit token background.
   - Same content + order as the Markdown: header (PR #/title/branch/base/scope), a verdict line, the summary line from item 3, a stat row (candidates / dropped / surviving / Critical-High-Med counts), the Scope-check block, each surviving finding as a card (severity badge + confidence + occurrences + a ```suggestion``` code block styled as an addition + rule references), a "below the bar" section for sub-80 correctness observations, and a "what was checked" footer.
   - Severity badges carry the emoji and are colour-coded, with 🟠 High visually distinct from 🔴 Critical. `❓ [q]` gets a neutral badge that reads as outside the severity scale.
   - Overwrite the file each run (one report, same path). Findings text is the source of truth — never invent findings that aren't in the Markdown.

6. **Post to PR** (only if `--post` AND a real PR was reviewed): posting a comment is an **outward-facing action** — show the exact comment body and **ask for confirmation before posting**. On approval, `gh pr comment <n> --body-file <tmpfile>`. The comment mirrors the Markdown (scope check + findings + summary line), kept brief, each finding citing `path:line`. Keep the severity prefixes — they are the scan layer — but no other decoration. If `--post` was passed in local-fallback mode (no PR), skip and say so.

## `--fix` mode

If `--fix` was passed, after the report apply the **safe** surviving fixes directly with Edit, preserving behavior. Do NOT run formatters or commit. A logic-bug fix that would change intended behavior is **reported, not auto-applied** — flag it for the author to confirm. `❓ [q]` items are questions, never fixes; leave them alone. After editing, remind the user to run the repo's own type-check + test commands for the touched packages/modules (discover them from `package.json` scripts / Makefile / `pyproject.toml` etc.).

---
Severity prefixes and the terse finding style are adapted from [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) (skills are MIT). The smell baseline and the two-axis rule are adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT).
