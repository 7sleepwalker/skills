---
name: make-skill
description: Author a new promoted skill for this repo — interview for its design, scaffold and wire it, then draft the body.
argument-hint: "[what the new skill should do]"
disable-model-invocation: true
---

# Make skill

Create a new promoted skill in this repo, end to end: settle its design by interview, scaffold and wire the files, then draft a real first body. Use it instead of hand-creating a skill directory and editing the manifest by hand.

This skill splits the work: **you** (the model) own the judgment — the design and the prose — and the script `scripts/new-skill.sh` owns the deterministic wiring that `check-manifest.sh` guards. See [../../../.agents/adr/0011-authoring-hybrid-skill-script.md](../../../.agents/adr/0011-authoring-hybrid-skill-script.md).

Promoted buckets only (`engineering`, `productivity`). This skill does not create `private/` skills; scaffold those by hand.

## 1. Settle the design

Apply the **baking** method to the new skill — the round-based interview in `baking`. On Claude Code, invoke it with the Skill tool (`boo:baking`); on any other agent, follow that method directly.

If arguments were passed, they are the starting subject. Interview until every one of these is settled, with a recommendation for each:

- **name** — kebab-case; becomes the directory and the frontmatter `name`.
- **bucket** — `engineering` (daily code work) or `productivity` (non-code workflow).
- **invocation** — `user` (takes over a session, fired only when typed) or `model` (the agent may reach for it mid-task). The test is in [../../../.agents/invocation.md](../../../.agents/invocation.md).
- **description** — one line. Human-facing if user-invoked; model-facing with trigger words if model-invoked.
- **purpose** — what the skill does and when it applies, and what it must *not* do.

Do not run the next step until these are settled.

## 2. Scaffold and wire

Run the script with the settled values:

```
scripts/new-skill.sh <bucket> <name> <user|model> "<description>"
```

It creates `skills/<bucket>/<name>/SKILL.md` from a template, adds the skill to `plugin.json` and both READMEs, re-links the skills, and runs `check-manifest.sh`. Do not edit `plugin.json` or the READMEs yourself — the script owns those; a hand-edit is what the script exists to prevent.

## 3. Draft the body

The template leaves a `TODO(make-skill)` marker where the body goes. Replace it, writing the real instructions with the **writing-for-agents** method. On Claude Code, invoke it with the Skill tool (`boo:writing-for-agents`); on any other agent, follow that method directly.

Keep the `**Plain language.**` clause the template already placed — `check-manifest.sh` requires it on every promoted skill. Follow the house checklist in [../../../.agents/writing-skills.md](../../../.agents/writing-skills.md): imperative voice, guardrails where they matter, capabilities named instead of tools, as short as it can be.

## 4. Verify and record

- Run `scripts/check-manifest.sh` again and confirm it prints `check-manifest: OK`.
- Add a `CHANGELOG.md` entry and, if this changes the plan, a `ROADMAP.md` Done line, in the same commit as the new skill.

**Plain language.** Write anything a person reads — questions, findings, summaries, reports — for a non-native English speaker: short sentences, one idea each, common words, no idioms or phrasal verbs. Keep technical terms and proper names exact (`null-check`, `race`) and never simplify code. Clear over clever.
