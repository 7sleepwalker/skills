# 0009. Capability language, not agent-specific tools

## Context

Skills were written naming Claude Code tools directly: the `Agent` tool for parallel fan-out, the `Skill` tool for cross-skill calls, `AskUserQuestion`, plan mode, `Grep`. A skill that names one harness's tools reads as runnable on one harness. The goal is agent-agnostic **content** — any agent that reads the prose can follow it — without giving up Claude Code's power (parallel subagents, plan mode) where it exists.

Two facts shape the fix:

- **A capability is shared; a tool name is not.** Every agent can "search the codebase" or "ask the user"; only some expose `Grep` or `AskUserQuestion`. Naming the capability keeps the instruction true everywhere. The tool is one harness's *way* of doing it.
- **The valuable Claude-only steps must not be lost.** `code-review`'s parallel fan-out and `bake-with-jira`'s plan-mode hand-off are real advantages on Claude Code. Stripping them for portability (the lowest-common-denominator option) would make every skill worse where it runs most.

Scope here is **content only**. Distribution to other agents (`AGENTS.md`, per-agent directories) is a separate, later decision; this ADR governs how the prose is written, not how it is loaded elsewhere.

## Decision

Write the **capability**, not the tool.

- Name what the step needs — "search the codebase", "spawn parallel workers", "ask the user", "apply the *<name>* method" — not `Grep` / the `Agent` tool / `AskUserQuestion` / a `Skill` call.
- **Conditional layering.** The portable path is the spine; a harness-specific accelerator is an optional layer, with the tool named *inside* the conditional: "review the passes in sequence; if your agent can run subagents, launch them at once instead." The document degrades instead of breaking.
- **Cross-skill calls become method references.** `bake-it`→`baking` reads "apply the baking method", with the `Skill`-tool call as the optional fast path — not a hard `Skill` dependency.
- **Frontmatter stays minimal-common** (`name`, `description`). Harness-specific fields (`allowed-tools`, `disable-model-invocation`) are additive: the agents that use them read them, the rest ignore them, so they stay.
- **Real external tools stay named.** `git`, `gh`, and MCP servers are not Claude-only; keep them, but gate an optional integration with "if available".
- The craft lives in `writing-for-agents` (`## Portability`); the enforceable one-liner lives in [../writing-skills.md](../writing-skills.md).

## Consequences

- Skill bodies read the same to any agent. Claude Code keeps its accelerators through the optional layer; other agents run the portable spine.
- This is **content only**. Other agents still will not *load* these skills until a distribution step (a single `AGENTS.md` pointer is the preferred route over per-agent replication — our bodies change, copies would rot). That step is tracked in `ROADMAP.md`, not decided here.
- **No mechanical enforcement yet.** `check-manifest.sh` does not detect a leaked tool name (`` `Agent` tool ``, `` `Grep` `` in a body). For now this is a review-time rule; a lint can be added if drift appears, the way the plain-language clause ([0006-plain-language-output.md](./0006-plain-language-output.md)) is enforced.
- Aligns with `mattpocock/skills`, whose bodies are already technique-level. We differ by keeping Claude accelerators **explicit** via conditional layering rather than omitting them — more power retained, a few more words.
- Precedent set by the pilot: `code-review` converted, `baking` confirmed already portable. `comment-on-pr`, `bake-it`, `bake-with-jira`, `handoff` follow (tracked in `ROADMAP.md`).
- Reverting is `git revert` of the introducing commit; the rule in `writing-skills.md` and the `## Portability` section revert with it.
