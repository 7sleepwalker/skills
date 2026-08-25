# Skills

My agent skills, in one place, version controlled.

They are small, opinionated, and meant to be edited. Nothing here assumes a particular project setup: no required config file, no setup step to run first.

## Install

**On this machine** (authoring): symlinks, so an edit is live in the next session.

```bash
git clone https://github.com/7sleepwalker/skills.git
cd skills
./scripts/link-skills.sh
```

**On another machine**: the repo is its own Claude Code marketplace.

```
/plugin marketplace add 7sleepwalker/skills
/plugin install kamil-skills
```

Pick one per machine. Both at once means every skill twice. See [.agents/adr/0001-dual-distribution.md](./.agents/adr/0001-dual-distribution.md).

## The skills

Skills split by who can invoke them. **User-invoked** skills fire only when I type them: they take over a session. **Model-invoked** skills are reachable by me or by the agent when the task fits.

### Engineering

**User-invoked**

- **[bake-with-jira](./skills/engineering/bake-with-jira/SKILL.md)**: Pick a Jira ticket assigned to me, read it properly, scout the repo, interview until the gaps are closed, then hand the plan to plan mode.

**Model-invoked**

- **[code-quality](./skills/engineering/code-quality/SKILL.md)**: PR review against the repo's own discovered standards, plus overcomplication, logic-bug risk, and scope match against the PR description and ticket. Parallel agents, HTML report, optional `--post` and `--fix`.
- **[diagnosing-bugs](./skills/engineering/diagnosing-bugs/SKILL.md)**: Six-phase loop for hard bugs and performance regressions. Build a tight feedback loop that goes red on this bug before theorising about it.

### Productivity

**User-invoked**

- **[bake-it](./skills/productivity/bake-it/SKILL.md)**: Turn a half-baked idea into a plan worth building, by relentless interview.
- **[handoff](./skills/productivity/handoff/SKILL.md)**: Compact this conversation into a handoff document a fresh agent can pick up.

**Model-invoked**

- **[baking](./skills/productivity/baking/SKILL.md)**: The interview primitive behind `bake-it`. Work the decision tree in rounds, ask the whole frontier at once, recommend an answer to every question.
- **[writing-for-agents](./skills/productivity/writing-for-agents/SKILL.md)**: How to write documents an agent actually follows: pointers, the information hierarchy, completion criteria, leading words, pruning.

## Working on this repo

[AGENTS.md](./AGENTS.md) holds the conventions, [ROADMAP.md](./ROADMAP.md) the live plan, [.agents/adr](./.agents/adr) the decisions, and [CREDITS.md](./CREDITS.md) the attribution for adapted skills.

| Command | What it does |
| --- | --- |
| `./scripts/link-skills.sh` | link every skill into `~/.claude/skills` |
| `./scripts/unlink-skills.sh` | remove this repo's symlinks |
| `./scripts/list-skills.sh` | list skills with bucket and invocation mode |
| `./scripts/check-manifest.sh` | verify the READMEs, the manifest, and the filesystem agree |

MIT licensed. Several skills are adapted from [mattpocock/skills](https://github.com/mattpocock/skills); see [CREDITS.md](./CREDITS.md).
