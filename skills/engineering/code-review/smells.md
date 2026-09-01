# Smell baseline

Agent Q2's fallback catalogue, from Fowler's *Refactoring* (ch. 3). It gives the review something to judge against when the repo documents no standards of its own.

Three rules bind everything below:

1. **The repo overrides this file.** Anything in the Step 0 standards wins outright. This baseline fills silence; it never argues with a rule the repo wrote down.
2. **Every smell is a judgement call, never a violation.** Phrase findings as "possible Feature Envy", not "violates Feature Envy" — a reason to look closer, not a verdict. Skip any smell the repo's tooling already enforces.
3. **Only raise a smell the diff can evidence.** Skip smells that don't fit the repo's language/paradigm — inheritance smells (Refused Bequest, Middle Man) in a repo with no inheritance, OO smells in a functional codebase. Skip smells that need a whole-codebase or historical view a single diff can't show (Divergent Change, Shotgun Surgery) unless the diff itself is the evidence.

Apply only to new/changed code in the diff, and only above the Step 3 confidence bar.

| Smell | What it is | How to fix |
| --- | --- | --- |
| **Mysterious Name** | A name that needs a comment to explain it. | Rename to the intent; if no good name fits, the thing does too much — split first. |
| **Duplicated Code** | The same structure in more than one place. | Extract a function; pull it up if the copies sit in sibling classes. |
| **Feature Envy** | A function more interested in another module's data than its own. | Move it to the data it envies; split first if only part envies. |
| **Data Clumps** | The same group of values travelling together through signatures and fields. | Make them an object. |
| **Primitive Obsession** | Domain concepts carried as raw strings/numbers/maps (money as `number`, a range as two fields). | Replace with a type that owns the concept and its rules. |
| **Repeated Switches** | The same switch/if-else on the same condition in several places. | Replace with polymorphism or a lookup keyed by the discriminant. |
| **Shotgun Surgery** | One change forces small edits across many files. | Gather the scattered pieces into one module. |
| **Divergent Change** | One module edited for unrelated reasons. | Split along the axes of change — one module per reason. |
| **Speculative Generality** | Machinery for a need nobody has yet: unused hooks, one-impl abstract bases, always-same parameters. | Delete it; add it back when the second case arrives. |
| **Message Chains** | `a.getB().getC().getD()` — the caller is coupled to the whole path. | Hide the delegation behind a method, or move the caller closer to what it wants. |
| **Middle Man** | A class whose methods nearly all just forward elsewhere. | Cut it out; let callers talk to the real object. |
| **Refused Bequest** | A subclass that overrides inherited members to throw or no-op. | Prefer delegation to inheritance, or push the unwanted members down to siblings. |
