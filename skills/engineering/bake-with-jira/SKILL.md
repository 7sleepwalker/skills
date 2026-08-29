---
name: bake-with-jira
description: Pick a Jira ticket assigned to me and bake it into an implementation plan.
argument-hint: "[ticket key or search terms]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Agent, Skill, AskUserQuestion, EnterPlanMode, ExitPlanMode, Write, mcp__atlassian__getAccessibleAtlassianResources, mcp__atlassian__searchJiraIssuesUsingJql, mcp__atlassian__getJiraIssue
---

# Bake with Jira

The user wants to start work on a ticket assigned to them in Jira. Pull the ticket, learn what the ticket does not say, interview until the gaps are closed, and hand the result to plan mode.

The failure this exists to prevent: planning from a ticket title, then discovering in review that the acceptance criteria, a linked blocker, or a decision buried in the comments changed the shape of the work.

## Step 1 — Reach Jira

Jira is only reachable through the `atlassian` MCP server. If the only atlassian tools available are `mcp__atlassian__authenticate` and `mcp__atlassian__complete_authentication`, the server is not authenticated: tell the user to run `mcp__atlassian__authenticate`, and stop. Never guess at ticket contents.

Call `getAccessibleAtlassianResources` for the `cloudId`. One site: use it. Several: ask which.

## Step 2 — Pick the ticket

If an argument matches `[A-Z]+-\d+`, that is the ticket. Skip to Step 3.

Otherwise call `searchJiraIssuesUsingJql`:

- `jql`: `assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC`
- `fields`: `summary`, `status`, `issuetype`, `priority`, `updated`
- cap at 20 results

Any other argument is a filter: add `AND text ~ "<argument>"` to the JQL.

Then:

- **No results**: say so and stop. Do not widen the query on your own.
- **One result**: name it and continue.
- **Several**: list them as `KEY — summary (status, type)` and put the choice to the user with the AskUserQuestion tool, so picking is one keypress. Never pick for them.

## Step 3 — Read the ticket properly

One `getJiraIssue` call, with `fields`: `summary`, `description`, `issuetype`, `status`, `priority`, `labels`, `components`, `parent`, `subtasks`, `issuelinks`, `comment`.

Report back, in a few lines: what is being asked, the acceptance criteria, anything already decided in the comments, blocking or linked issues, and subtasks.

Then state plainly what the ticket does **not** answer. Those gaps are the interview's raw material.

## Step 4 — Light recon

One `Agent` call with `subagent_type: Explore`, scoped to the area the ticket names, over the repo this session is already in. Ask it for three things: the files that would change, the existing pattern to follow, and how that area is tested.

If the working directory is clearly not the ticket's repo, ask which repo before running recon.

One pass. Do not fan out, and do not read the whole subsystem yourself.

## Step 5 — Bake it

Call the Skill tool with "boo:baking".

The subject is the ticket plus the recon findings. Hand those over as established facts, so the interview does not spend questions on what Steps 3 and 4 already answered. Facts are yours; decisions are the user's.

## Step 6 — Hand off to plan mode

Only once the user has confirmed the interview's summary. An empty frontier is not permission to act.

If the session is not already in plan mode, call `EnterPlanMode`. Write the plan to the plan file:

- title: `KEY — summary`, with the ticket URL underneath
- **Context**: why this work exists, from the ticket
- the decisions settled in the interview
- the files to change, from recon
- how to verify the work end to end

Call `ExitPlanMode`. Do not start implementing.

Tell the user the ticket key doubles as the `TICKET` argument to `/boo:code-review` when the PR is up.

## What not to do

- Do not write to Jira. No comments, no transitions, no assignment or field changes.
- Do not paste the ticket back wholesale. Summarise.
- Do not skip the interview because the ticket looks clear.
- Do not put a real ticket key, project key, or site hostname in this file. It is tracked and public; those belong to the run, not the skill.
