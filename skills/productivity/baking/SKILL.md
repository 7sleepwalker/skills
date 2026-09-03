---
name: baking
description: The interview engine behind bake-it and bake-with-jira — work the decision tree in rounds, ask the whole frontier at once, recommend an answer to every question, until every branch is settled. Use when the user wants to stress-test a plan or decision, says "bake it" / "half-baked" / "poke holes in this" / "interview me first", or a request is too underspecified to act on safely.
---

# Baking

Interview the user until you and they share one understanding of what is being built. Nothing is assumed silently; nothing half-baked survives the session.

Model the work as a **decision tree**: every decision branches into the decisions that hang off it. Your job is to visit every branch.

**Plain language.** Write anything a person reads — questions, findings, summaries, reports — for a non-native English speaker: short sentences, one idea each, common words, no idioms or phrasal verbs. Keep technical terms and proper names exact (`null-check`, `race`) and never simplify code. Clear over clever.

## Rounds

Work the tree in rounds.

The **frontier** is every decision whose prerequisites are already settled: the questions answerable *now*, without guessing at answers you have not heard yet. Ask the entire frontier in one round, then stop and wait.

A question whose answer depends on another question still open in this round is not on the frontier. It belongs to a later round.

Format a round exactly like this:

```
❓ **Q1** — **<short title>**: <the question, as long as it needs to be>
   (a) <option> (b) <option> (c) <option>

➡️ <your recommended answer, and why>

---

❓ **Q2** — **<short title>**: <question>

➡️ <your recommended answer, and why>
```

Always give a recommendation. A question with no recommendation pushes work back onto the user that you could have done.

Where a question has discrete options, letter them so the user can answer compactly (`1a 2b`). Per question, "not sure — take your recommendation" is a valid answer, and you adopt your ➡️ for that one question. This is a decision on a single question, not a way to wave through the whole round: there is no accept-all, because the point of baking is that the user weighs each branch.

Each round's answers reshape the tree: settled decisions push the frontier outward and unblock what depended on them. Recompute the frontier, ask the next round.

## Facts are yours, decisions are theirs

Never ask the user something you could find out. If a frontier question needs a fact from the environment (what the code does, what a dependency exposes, what the config says, what the docs say), go get it: read files, search the codebase, run a tool.

Do not block the round on a lookup. An unfinished investigation is just an unsettled prerequisite: the questions downstream of it wait, the rest of the frontier gets asked now.

The **decisions** are always the user's. Put each one to them and wait for the answer. Do not decide on their behalf, and do not treat your recommendation as accepted until they say so.

## Ending

The session is done when the frontier is empty: every branch visited, nothing left implicit.

Then summarise the settled design in a few lines and ask the user to confirm. **Do not start building until they confirm.** Reaching an empty frontier is not permission to act.