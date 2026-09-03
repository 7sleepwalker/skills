---
name: comment-on-pr
description: Review a PR with code-review, then post each finding as an inline PR comment, asking before every one.
disable-model-invocation: true
argument-hint: "[PR#|url] [TICKET]"
allowed-tools: Skill, Bash(gh pr view:*), Bash(gh api:*), Bash(gh pr comment:*), Write
---

# Comment on a PR

Review a PR, then post its findings back as **inline review comments** — one per finding, anchored to the exact line, each in a plain human voice. You show every comment and **ask before posting it**. Nothing reaches the PR without a yes.

The review itself is not reimplemented here: `boo:code-review` produces the findings. This skill owns only the voice and the per-comment gate.

Guardrails that never change:
- **One yes, one comment.** Never post a comment the user has not approved this run. No "post all".
- **Never invent a finding.** Every comment traces to a `code-review` finding. If it wasn't found, it isn't posted.
- **A finding with no anchorable line is surfaced, never dropped and never silently retargeted.** Offer it as a general PR comment or skip it — the user chooses.
- **Plain language.** Write anything a person reads — questions, findings, summaries, reports — for a non-native English speaker: short sentences, one idea each, common words, no idioms or phrasal verbs. Keep technical terms and proper names exact (`null-check`, `race`) and never simplify code. Clear over clever.

## Step 1 — Get the findings

Call the Skill tool with `boo:code-review`, passing the same PR selector and ticket the user gave you (a bare number, a PR URL, or nothing to auto-detect the current branch's PR). Let it run to completion.

Take its **ranked findings** and its **scope check** from that output. You will turn each finding into one comment. The scope check is not a line-anchored finding — hold it for Step 4.

If `code-review` produced no qualifying findings, say so and stop. Nothing to post.

If `code-review` fell back to a local diff (no real PR), there is nowhere to post. Say so and stop.

## Step 2 — Resolve the PR head

Inline comments attach to a commit. This step and Step 3a need `gh` working: if `gh` is missing or not authenticated (`gh auth status` fails), say so and stop — there is nowhere to post. Otherwise fetch the PR number and its head SHA once:

```
gh pr view <n> --json number,headRefOid,url
```

Keep `headRefOid` — every inline comment uses it as `commit_id`. If the PR head moves while you work (someone pushes), re-fetch before posting the rest.

## Step 3 — Turn each finding into a comment, gated

Work the findings in ranked order (most severe first). For **each** finding:

1. **Decide the anchor.** The comment attaches to a `path` and a `line` that must be part of the PR diff (the new side). Use the finding's `file:line`. If the finding lists several occurrences, pick the clearest one and mention the rest in the body. If the finding has no line in the diff (a missing test, an absent null-check, a scope gap), it cannot be inlined — mark it for Step 4.

2. **Write the comment in the voice below.** Plain, short, strict, human. Not the report's `Impact:/Fix:` scaffolding, no severity badges.

3. **Show it and ask.** Print the target (`path:line`) and the exact body, then ask: **post / skip / edit?** Wait for the answer.
   - **post** → run the command in Step 3a.
   - **skip** → move on, post nothing.
   - **edit** → take the user's rewording, show it again, ask again.

Do not batch the questions. One finding, one prompt, one answer, then the next.

### Step 3a — Post one inline comment

Write the approved body to a temp file (avoids shell-escaping), then:

```
gh api repos/{owner}/{repo}/pulls/<n>/comments \
  -f commit_id=<headRefOid> \
  -f path=<path> \
  -F line=<line> \
  -f side=RIGHT \
  -F body=@<tmpfile>
```

`{owner}/{repo}` is filled in by `gh` from the current repo — leave it literal. `-F line=` is numeric; `side=RIGHT` is the new version of the file (use `LEFT` only to comment on a removed line). For a range, add `-F start_line=<n>` before `line`. Report success or the exact error; on error, do not silently retry — show it and ask.

## Step 4 — Findings with no line

For each finding held from Step 3 (and the scope check, if the user wants it posted): show the body, ask **post as a general comment / skip?**. On post:

```
gh pr comment <n> --body-file <tmpfile>
```

## Step 5 — Close

One line: how many posted inline, how many general, how many skipped. Link the PR.

## The comment voice

The reviewer is a person who is direct and easy to read. Every comment:

- **One point.** One comment per problem. Never bundle two findings.
- **Plain language.** Say the problem, why it bites, and the fix, in that order. No jargon the diff doesn't already use. 1–3 sentences.
- **Strict, not soft.** State it. "This drops the error" — not "you might consider possibly handling the error here". No "I think", "maybe", "it seems", "consider". If it's a question, ask it outright.
- **Not mechanical.** No `Impact:`/`Fix:`/`References:` labels, no 🔴/🟠 badges, no confidence scores — those live in the report, not on the PR.
- **A concrete fix when there is one.** Use a GitHub suggestion block so the author can apply it in one click:

  ````
  This runs on every render because the object is rebuilt each time. Memoize it:

  ```suggestion
  const config = useMemo(() => ({ id }), [id]);
  ```
  ````

- **Honest about doubt.** If you're not sure it's wrong, say what you suspect and ask — don't assert a bug you can't stand behind.

Good: `Off-by-one here — < lets the last valid token expire a second early. Use <=.`
Bad: `It seems like there might be a potential issue with the boundary condition that you may want to look into.`
