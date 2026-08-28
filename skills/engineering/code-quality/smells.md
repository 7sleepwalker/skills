# Smell baseline

The fallback catalogue for Agent Q2, from Fowler's *Refactoring* (ch. 3). It exists so a review still has something to judge against when the repo documents no standards of its own.

Two rules bind everything below.

1. **The repo overrides this file.** Anything in the standards discovered in Step 0 wins outright. This baseline fills silence; it never argues with a rule the repo actually wrote down.
2. **Every smell is a judgement call, never a violation.** Phrase findings as "possible Feature Envy", not "violates Feature Envy". A smell is a reason to look closer, not a verdict. Skip any smell the repo's own tooling already enforces — CI and pre-commit own those.

Apply these only to new or changed code in the diff, and only where the confidence bar in Step 3 is met.

| Smell | What it is | How to fix |
| --- | --- | --- |
| **Mysterious Name** | A name that doesn't say what the thing is or does. Reveals itself when you need a comment to explain the name. | Rename to the intent. If no good name exists, the thing is probably doing more than one job — split it first. |
| **Duplicated Code** | The same structure in more than one place. Identical text, or the same shape with different names. | Extract a function. If the copies sit in sibling classes, pull the method up. Differences that look blocking are usually parameters. |
| **Feature Envy** | A function more interested in another module's data than its own — reaching repeatedly across a boundary to compute something. | Move the function to the data it envies. Split it first if only part of it envies. |
| **Data Clumps** | The same group of values travelling together through signatures and fields. Three or more, always adjacent. | Make them an object. Test: remove one value — if the rest stop making sense, they're a real clump. |
| **Primitive Obsession** | Domain concepts carried as strings, numbers, or maps: a phone number as `string`, money as `number`, a range as two fields. | Replace with a type that owns the concept and its rules. |
| **Repeated Switches** | The same `switch` or `if/else` chain on the same condition, in several places. Adding a case means editing all of them. | Replace with polymorphism, or a lookup keyed by the discriminant. |
| **Shotgun Surgery** | One change forces small edits across many files. The concern is smeared. | Pull the scattered pieces into one module, so the next change lands in one place. |
| **Divergent Change** | The inverse: one module edited for unrelated reasons. Two changes, two different sets of lines. | Split along the axes of change — one module per reason to change. |
| **Speculative Generality** | Machinery built for a need nobody has yet: unused hooks, abstract bases with one implementation, parameters always passed the same value. | Delete it. Inline the lone subclass, drop the unused parameter. Add it back when the second case actually arrives. |
| **Message Chains** | `a.getB().getC().getD()` — the caller is coupled to the whole path, not just its ends. | Hide the delegation behind a method on the first object, or move the calling code closer to what it wants. |
| **Middle Man** | A class whose methods nearly all just forward somewhere else. The indirection buys nothing. | Cut out the middle man and let callers talk to the real object. |
| **Refused Bequest** | A subclass that inherits members it doesn't want, and overrides them to throw or no-op. | Prefer delegation to inheritance, or push the unwanted members down to the siblings that do want them. |
