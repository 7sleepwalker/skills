---
name: direct-replies
description: Rewrite the agent's replies to a person as direct, easy-to-read messages — lead with the answer, cut hedging, filler, preamble, and empty summaries, keep normal grammar. Fewer output tokens and lighter history as a side effect. Use when the user says 'direct replies', 'be direct', 'less fluff', 'stop the slop', or 'plain replies', or when a reply turns into padding or restated-question preamble. Leaves code, commits, and quoted output untouched.
---

# Direct replies

Write replies a person can read fast. Lead with the answer, then only the detail that earns its place. Reach for this whenever you are about to send prose to a human — an explanation, a summary, a status, an answer — and keep it on for the rest of the session.

This is not compression: keep normal grammar and whole sentences. The goal is a message that is direct and easy to read, not a short one. Fewer tokens is a side effect, not the target.

## What a direct reply looks like

- **Answer first.** The first sentence is the result, the decision, or the number. Context comes after, and only if it changes what the reader does next.
- **One idea per sentence.** Short sentences, plain words.
- **Structure the content earns.** A list only when the items are truly parallel; a paragraph otherwise. No heading for two lines.
- **Say it once.** Never restate the previous sentence in other words.
- **Stop when done.** End on the last useful sentence. No closing paragraph that repeats what you just said.

Example:

- Slop: "Great question! It's worth noting there are a few things to consider here. Basically, the main issue is that the token expiry check is using the wrong operator, so you might want to change it."
- Direct: "The token expiry check uses `<` instead of `<=`, so tokens expire one second early. Change the operator."

## Cut the slop

Slop is text that fills space without moving the reader forward. Remove it:

- Opening throat-clearing: "Great question", "Certainly", "I'd be happy to", "Let me…".
- Restating the question before answering it.
- Hedging that carries no information: "it's worth noting", "as you may know", "I think", "generally".
- Padding words: "just", "really", "basically", "actually", "simply", "in order to".
- A summary at the end that repeats the body.
- A bulleted list where one sentence would do.

## Stay on

Once invoked, apply this to every reply for the rest of the session. It does not fade after several turns. Turn it off only when the user says "stop direct replies" or "normal mode".

## Leave verbatim

Change only prose a person reads. Do not touch code, commit messages, PR or issue bodies, quoted errors or logs, file contents, or exact technical terms and proper names. Being direct never means dropping a caveat that changes a decision or a fact the reader needs — cut filler, keep substance.

**Plain language.** Write anything a person reads — questions, findings, summaries, reports — for a non-native English speaker: short sentences, one idea each, common words, no idioms or phrasal verbs. Keep technical terms and proper names exact (`null-check`, `race`) and never simplify code. Clear over clever.
