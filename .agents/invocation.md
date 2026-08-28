# Invocation: who can reach a skill

Every `SKILL.md` here is a skill. The axis that splits them is **who can invoke it**.

## Model-invoked (the default)

Reachable by the model or by me typing its name. Omit `disable-model-invocation` from the frontmatter.

The `description` is **model-facing**. It is the only thing the model sees when deciding whether to reach for the skill, so it carries the triggers: "Use when the user wants..., mentions..., asks for...". Name the concrete words and situations that should fire it.

The test for model-invoked: *could the model usefully reach for this on its own, mid-task, without being asked?* Reuse alone is not the test. A block of shared reference material that only ever runs as part of a bigger flow is still model-invoked, because that bigger flow reaches it by calling the Skill tool.

## User-invoked

Reachable **only when I type it**. Set `disable-model-invocation: true`.

The `description` is **human-facing**: one line, read by a person scanning a slash-command list. No trigger phrasing, no "use when the user says" - nothing is listening for those.

User-invoked is for skills that own a whole session: they orchestrate, they interrogate, they take over. Firing one uninvited is disruptive, which is exactly why the model cannot.

## The rules between them

- A user-invoked skill **may** invoke model-invoked skills.
- A user-invoked skill can **never** reach another user-invoked skill. Nothing but me can fire one. If a skill's step depends on one, phrase it as an instruction to the human: "tell the user to run `/boo:bake-it`", never as a tool call.
- A model-invoked skill may invoke other model-invoked skills.

## How a skill invokes another skill

Write it as an explicit instruction to call the tool, naming the skill:

> Call the Skill tool with "boo:baking".

Not a bare `/boo:baking` in prose, and not a relative link into the other skill's files. Naming the tool is what actually gets it fired; a `/name` dropped into a sentence is left for the model to interpret as a command, and often is not.

One skill per call. A step needing two is two calls: "Call the Skill tool twice, for `boo:baking` and `boo:writing-for-agents`", not "call it with both".

Shared reference material lives inside the skill that owns it. Other skills reach it by calling the Skill tool, never by linking across skill folders. Router prose that just lists skill names for a human to pick from is not invoking anything, and can use plain `/name` labels.

## The `boo:` namespace

Promoted skills load as a skills-directory plugin named `boo`, so their invocation name is `boo:<skill-name>` — both for the Skill tool and for slash commands. Always write the prefix; do not rely on the bare name resolving. Private skills are linked separately and keep their bare names.

See [adr/0005-boo-namespace.md](./adr/0005-boo-namespace.md).
