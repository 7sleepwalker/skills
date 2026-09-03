---
name: handoff
description: Compact this conversation into a handoff document a fresh agent can pick up.
argument-hint: "[what the next session will focus on]"
disable-model-invocation: true
---

# Handoff

Write a document that lets a fresh agent, with none of this context, continue the work.

Save it to the OS temporary directory (`${TMPDIR:-/tmp}`, resolved to an absolute path), **never** into the workspace. Finish by printing the absolute path.

**Plain language.** Write anything a person reads — questions, findings, summaries, reports — for a non-native English speaker: short sentences, one idea each, common words, no idioms or phrasal verbs. Keep technical terms and proper names exact (`null-check`, `race`) and never simplify code. Clear over clever.

## What goes in

- **Goal**: what we are trying to achieve, in two or three sentences.
- **State**: what is done, what is in flight, what is untouched.
- **Decisions made**: the ones with reasons, especially where an obvious-looking alternative was rejected and why.
- **Traps**: what was tried and failed, what looks wrong but is deliberate, what breaks if touched.
- **Next steps**: concrete and ordered.
- **Suggested skills**: which skills (methods) the next agent should apply, and when.

## What stays out

- Anything already captured elsewhere. Plans, specs, ADRs, issues, commits, and diffs get **referenced by path or URL**, never restated. A handoff that duplicates a plan file goes stale the moment the plan changes.
- Narration of the conversation. The next agent needs the state, not the transcript.
- Secrets. Redact API keys, tokens, passwords, and personal data, even when they appeared in the conversation.

If arguments were passed, treat them as what the next session will focus on and weight the document toward that: the same state, filtered for what that task needs.