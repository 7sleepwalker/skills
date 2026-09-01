---
name: diagnosing-bugs
description: Disciplined diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose", "debug this", "why is this happening", or reports something broken, throwing, failing, flaky, or slow, and the cause is not obvious from the error alone.
---

# Diagnosing bugs

For bugs where the cause is not obvious. Six phases, in order. Skipping one is allowed only when you say out loud which one and why.

The failure this discipline exists to prevent: reading code, forming a theory, and "fixing" it, with nothing that can prove the theory wrong.

**Plain language.** Write anything a person reads — questions, findings, summaries, reports — for a non-native English speaker: short sentences, one idea each, common words, no idioms or phrasal verbs. Keep technical terms and proper names exact (`null-check`, `race`) and never simplify code. Clear over clever.

## Redact first

This skill has you paste commands, output, and captured payloads. Replace every secret with `<REDACTED>` before showing it. Keep credentials in environment variables so they never appear in a command you print. Captured traffic carries auth headers: quote only the lines that carry signal.

If the redacted output is not enough to diagnose the bug, say so and ask.

## Phase 1: Build a feedback loop

**This is the whole skill.** With a tight pass/fail signal that goes red on *this* bug, you will find the cause; bisection, hypotheses, and instrumentation all just consume that signal. Without one, no amount of reading code will save you.

Spend disproportionate effort here.

Ways to build one, roughly in order of preference:

1. **Failing test** at whatever seam reaches the bug.
2. **HTTP call** (curl, a script) against a running dev server.
3. **CLI invocation** with a fixture input, diffed against known-good output.
4. **Headless browser script** driving the UI, asserting on DOM, console, or network.
5. **Replayed capture**: save the real request, payload, or event log, replay it through the code path in isolation.
6. **Throwaway harness**: the smallest slice of the system that hits the bug in one function call.
7. **Fuzz loop**: for "sometimes wrong", run hundreds of inputs and count failures.
8. **Bisection harness**: if it appeared between two known states, automate "boot at state X, check", then `git bisect run` it.
9. **Differential loop**: same input through two versions or two configs, diff the outputs.
10. **Human in the loop**: last resort, when only a person can click. Script the steps and the capture so the loop is still structured, and feed the output back.

### Tighten it

Once you have *a* loop, treat it as a product and sharpen it:

- **Faster**: cache setup, skip unrelated init, narrow scope.
- **Sharper**: assert the specific symptom, not "did not crash".
- **More deterministic**: pin time, seed randomness, isolate the filesystem, freeze the network.


For non-deterministic bugs the goal is not a clean repro, it is a **higher reproduction rate**: loop the trigger, parallelise, add load, inject sleeps to widen the timing window. 50% is debuggable, 1% is not. Keep raising it.

### If you truly cannot build one

Stop. Say so, list what you tried, and ask for one of: access to an environment that reproduces it, a redacted artifact (HAR, log dump, recording with timestamps), or permission to add temporary instrumentation where it does reproduce. **Do not move to Phase 3 without a loop.**

### Done when

You can name **one command** you have **already run**, and shown (redacted), that is:

- **Red-capable**: drives the real code path and asserts the user's exact symptom. It can go red on this bug and green when fixed.
- **Deterministic**: same verdict every run, or a pinned high reproduction rate.
- **Fast**: seconds.
- **Unattended**: you can run it yourself, repeatedly.

If you catch yourself theorising before this command exists, stop and go back.

## Phase 2: Reproduce, then minimise

Run the loop. Watch it go red.

Confirm it is the **user's** failure, not a different one nearby. Wrong bug, wrong fix. Capture the exact symptom, so later phases can prove the fix addressed it.

Then shrink: cut inputs, callers, config, data, and steps **one at a time**, re-running after each cut. Done when every remaining element is load-bearing, meaning removing any one of them turns the loop green.

Minimising is not tidiness. It shrinks the hypothesis space in Phase 3 and becomes the regression test in Phase 5.

## Phase 3: Hypothesise

Write **3 to 5 ranked hypotheses before testing any of them**. One hypothesis at a time means anchoring on the first plausible story.

Each must be falsifiable, stated as a prediction:

> If X is the cause, then changing Y makes the bug disappear, and changing Z makes it worse.

No prediction means it is a vibe. Sharpen it or drop it.

Show the ranked list to the user before testing. They often re-rank it in one sentence ("we deployed a change to #3 yesterday") or have already ruled one out. Do not block on the reply: if they are away, proceed with your ranking.

## Phase 4: Instrument

Every probe maps to a specific prediction from Phase 3. **Change one variable at a time.**

1. Debugger or REPL inspection where the environment allows it. One breakpoint beats ten logs.
2. Targeted logs at the boundaries that separate the hypotheses.
3. Never "log everything and grep".

Tag every debug log with a unique prefix, for example `[DEBUG-a4f2]`, so cleanup is one grep. Untagged debug logs survive forever.

**Performance regressions take a different path.** Logs are usually the wrong tool: establish a baseline measurement (timing harness, profiler, query plan), then bisect against it. Measure first, fix second.

## Phase 5: Fix, with a regression test

Write the regression test **before the fix**, if there is a correct seam for it.

A correct seam exercises the real bug pattern as it occurs at the call site. A seam too shallow to reproduce the chain that triggered the bug gives false confidence, which is worse than no test.

**If no correct seam exists, that is itself a finding.** Say so. The architecture is preventing the bug from being locked down, and that is worth more than the fix.

Where a seam exists: turn the minimised repro into a failing test, watch it fail, apply the fix, watch it pass, then re-run the Phase 1 loop against the original un-minimised scenario.

## Phase 6: Clean up

Not done until all of these are true:

- The original repro no longer reproduces (re-run the Phase 1 loop).
- The regression test passes, or the missing seam is documented.
- Every `[DEBUG-...]` line is gone. Grep the prefix.
- Throwaway harnesses are deleted, or moved somewhere clearly marked.
- The hypothesis that turned out to be right is named in the commit or PR message, so the next person debugging this area learns something.

---
Adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT).
