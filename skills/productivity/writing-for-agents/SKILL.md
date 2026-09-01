---
name: writing-for-agents
description: How to write documents an agent will actually follow. Use when creating or editing a skill, an AGENTS.md or CLAUDE.md, a prompt template, or any doc an agent reaches through a pointer.
---

# Writing for agents

A skill, an `AGENTS.md`, a doc reached by a pointer: the packaging differs, the writing does not. The target is not a document that reads well. It is a document that makes the agent take the same **process** every run.

For the mechanical rules of skills in this repo (folder shape, frontmatter, invocation), read `.agents/writing-skills.md` at the repo root. This skill is the craft; that file is the checklist.

**Plain language.** This applies to what you say to the *user* — explanations, findings, questions — not to the agent-facing docs you author here, which follow the rules below. When you write for a person, write for a non-native English speaker: short sentences, one idea each, common words, no idioms or phrasal verbs. Keep technical terms and proper names exact and never simplify code. Clear over clever.

## Pointers

A **pointer** is a line in context that names material sitting outside context and encodes when to go get it. A skill description is a pointer. So is a line in `AGENTS.md` naming a doc.

The pointer's **wording**, not its target, decides whether the material gets reached. Great material behind a vague pointer is dead material. Sharpen the wording before you consider inlining the content.

A pointer does two jobs: say what the material is, and name the **branches** that should trigger it. Since it costs tokens on every single turn, prune it harder than the body:

- Front-load the word that does the triggering.
- One trigger per branch. Two synonyms for the same case are one branch written twice.
- Cut identity the body already states.

## The two budgets

- **Context load**: what always-loaded material costs the agent, every turn, whether or not it fires.
- **Cognitive load**: what it costs the human to know which documents exist and when to reach for each.

Material behind a pointer escapes context load for the price of one line. Material with no pointer rides entirely on the human's memory. Cognitive load is not automatically bad: it is the price of human agency. Spend it where judgement matters, remove it where it does not.

## The hierarchy

Documents hold two content types: **steps** (ordered actions) and **reference** (rules and facts consulted on demand). They mix freely. The real decision is how far down each piece sits:

1. **In-file step**: what the agent does, in order. The top tier.
2. **In-file reference**: consulted on demand. A flat list of peer rules on one rung is fine, not a smell.
3. **Disclosed reference**: pushed into a separate file behind a pointer, loaded only when the pointer fires.

**Progressive disclosure** is the move down that ladder. The test is branching: inline what every branch needs, disclose what only some branches reach. In a document with steps, undisclosed reference buries them and turns following them into a coin flip.

**Co-location** is the within-file version: a concept's definition, rules, and caveats live under one heading, so reading one part brings its neighbours. Scattered meaning reads like notes; grouped meaning reads like documentation.

**Sprawl** is the failure mode: a document too long even though every line is live. Attention thins across the excess. Cure it with the ladder, or split by branch or sequence.

## Completion criteria

Every step ends on a condition that says the work is done. Two properties make it a lever:

- **Clarity**: can the agent tell done from not-done? A fuzzy bound ("understanding reached") invites finishing early, because the steps still visible ahead pull attention toward being done. Sharpen the bound first, it is cheap and local. Only if it is irreducibly fuzzy *and* you see the rush, split the sequence so the later steps are out of view. That works only across a real context boundary, such as a hand-off or a sub-agent.
- **Demand**: how much it asks for. "Every modified model accounted for" forces digging that "produce a change list" does not. Demand binds reference too: "every rule applied" holds a flat rule set to the same bar.

The strongest criteria are checkable *and* exhaustive.

## Leading words

A **leading word** is a compact concept the model already holds from pretraining, which the agent thinks with while running the document: *tight*, *red*, *seam*, *tracer bullet*. Repeat it as a token, never as a restated sentence, and it anchors a whole region of behaviour for almost no tokens.

It anchors twice. In the body, it makes the agent reach for the same behaviour every time the word appears. In a pointer, shared vocabulary between your prompts, docs, and code makes the material easier to find.

Hunt for passages that collapse into one word:

- "fast, deterministic, low-overhead" becomes *tight*.
- "a loop you believe in" becomes *red*, a binary observable state instead of a vibe.

Coining your own word works only if you define it, and you pay in definition tokens what a pretrained word gives free. Reach for the existing word first.

**Prompt the positive.** Steering by prohibition drags the forbidden thing into context and makes it more available, not less. State the target behaviour so the banned one is never named. Keep a prohibition only as a hard guardrail you cannot phrase positively, and even then pair it with the positive target.

## Pruning

- **One source of truth per meaning.** The same rule in two places costs tokens, costs maintenance, and inflates that rule's apparent rank.
- **The environment is a source of truth.** `package.json` scripts, config, directory layout, `--help` output. A document restating those is a cache, and a cache earns its keep only when the lookup is expensive. Cache the unwritten convention, the reason behind a choice, the gotcha no config confesses. Leave one-command lookups to the environment, where they cannot go stale.
- **Check relevance line by line.** A line dies by never bearing on the task, or by going stale. Without a pruning habit the default is sediment: layers nobody dares remove, until finding what is live means digging.
- **Delete no-ops.** An instruction the model already follows by default pays load to say nothing. The test is behavioural, not aesthetic: does the document behave differently without this line? Settle disagreements by running it, not by arguing. When a sentence fails the test, delete the sentence rather than trim it. This also grades leading words: a word too weak to beat the default is a no-op, and the fix is a stronger word, not a different technique.