# Writing a skill in this repo

House rules. Every `SKILL.md` here follows them; `scripts/check-manifest.sh` enforces the mechanical ones.

For the technique of writing prose an agent will actually follow, call the Skill tool with "writing-for-agents". This file is the checklist; that skill is the craft.

## Shape on disk

```
skills/<bucket>/<skill-name>/
├── SKILL.md          required
└── <companion>.md    optional, linked relatively from SKILL.md
```

- `<bucket>` is `engineering`, `productivity`, or `private`.
- `<skill-name>` is kebab-case and **must equal** the frontmatter `name`.
- One skill per directory. No nesting skills inside skills.
- Companion files hold detail that would bloat `SKILL.md`: examples, formats, long checklists. Link them relatively (`[tests.md](tests.md)`) and say when to read them.

## Frontmatter

```yaml
---
name: bake-it
description: One line, human-facing, because this one is user-invoked.
disable-model-invocation: true
argument-hint: "[topic]"
allowed-tools: Read, Grep, Bash(git diff:*)
---
```

| Field | Required | Notes |
| --- | --- | --- |
| `name` | yes | kebab-case, equals the directory name |
| `description` | yes | model-facing with triggers, or human-facing one-liner if user-invoked. See [invocation.md](./invocation.md) |
| `disable-model-invocation` | only if user-invoked | `true`. Omit entirely otherwise |
| `argument-hint` | optional | shown in the slash-command UI |
| `allowed-tools` | optional | narrows what the skill may use. Keep it honest: every tool the skill actually calls must be listed, and nothing else |

No colons in an unquoted `description`. Quote the whole value if it needs one.

## Writing the body

- Open with what the skill does and when it applies, in two or three sentences. No preamble about being helpful.
- Write instructions to the agent, imperative, second person. "Read the diff", not "the agent should read the diff".
- Steps that must happen in order get numbered headings. Steps that are reference material get prose.
- Say what **not** to do where it matters. Guardrails prevent more damage than instructions create.
- Name real tools and commands. Vague pointers get ignored.
- Cross-skill dependencies are Skill tool calls, never file links. See [invocation.md](./invocation.md).
- Keep it as short as it can be and still be unambiguous. Length is not thoroughness; every extra paragraph is context the agent spends.

## Adapted skills

A skill derived from someone else's work carries a footer:

```
---
Adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT).
```

and a row in [CREDITS.md](../CREDITS.md). Adapt means rewrite: our voice, our defaults, no upstream prerequisites. See [adr/0004-adapt-not-vendor.md](./adr/0004-adapt-not-vendor.md).

## Before you commit

1. `./scripts/check-manifest.sh`
2. `./scripts/link-skills.sh` if a skill was added or renamed
3. Update `ROADMAP.md` if this changes what is planned
