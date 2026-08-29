# Credits

Skills here that started from someone else's work. Each is a rewrite, not a copy: see [.agents/adr/0004-adapt-not-vendor.md](./.agents/adr/0004-adapt-not-vendor.md).

## [mattpocock/skills](https://github.com/mattpocock/skills) (MIT)

| Mine | Upstream |
| --- | --- |
| [baking](./skills/productivity/baking/SKILL.md) | `skills/productivity/grilling` |
| [bake-it](./skills/productivity/bake-it/SKILL.md) | `skills/productivity/grill-me` |
| [handoff](./skills/productivity/handoff/SKILL.md) | `skills/productivity/handoff` |
| [writing-for-agents](./skills/productivity/writing-for-agents/SKILL.md) | `skills/productivity/writing-for-agents` |
| [diagnosing-bugs](./skills/engineering/diagnosing-bugs/SKILL.md) | `skills/engineering/diagnosing-bugs` |
| [code-quality](./skills/engineering/code-quality/SKILL.md) | `skills/engineering/code-review` — the Fowler smell baseline in [smells.md](./skills/engineering/code-quality/smells.md), and the rule that review axes are never merged or reranked |

The repo layout (bucket folders, the invocation split, the symlink script, the plugin manifest pairing) also follows that repo's shape.

## [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) (skills are MIT)

That repo is split-licensed — MIT covers the skills, BSL-1.1 covers the engine and runtime modules. Only the skill was read.

| Mine | Upstream |
| --- | --- |
| [code-quality](./skills/engineering/code-quality/SKILL.md) | `skills/caveman-review` — the severity prefixes, the `q` category that replaces hedging, and the terse finding style with its carve-outs for security and architecture |

## [trailofbits/skills](https://github.com/trailofbits/skills) (CC-BY-SA-4.0)

Technique only — the idea was adapted and the prose rewritten from scratch, so no share-alike derivative attaches; credited here regardless.

| Mine | Upstream |
| --- | --- |
| [code-quality](./skills/engineering/code-quality/SKILL.md) | `differential-review` — blast radius (weigh a finding by how many callers the changed symbol reaches) and using `git blame` to spot regressions in previously-fixed lines |
