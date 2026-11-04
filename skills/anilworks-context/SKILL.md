---
name: anilworks-context
description: Creates and maintains personal work journals under anilworks/ for Applaud features and bugs — what was done, outcomes, deploy order, and verification so future sessions can resume without re-discovery. Use when starting a new feature or bug, continuing a ticket (AC-780, AIA-*, etc.), finishing a debugging session, or when the user mentions anilworks, work context, or reworking a past item.
---

# Anilworks context journals

Persistent notes for **Anil's** cross-repo work. One markdown file per ticket (or tightly related thread). Agents read the matching file **before** deep investigation when the user names a ticket or opens a related topic.

## Location

| Scope | Path |
|-------|------|
| Workspace (default) | `~/applaud/anilworks/` |
| Per-repo (optional) | `docs/anilworks/` inside a repo if the work is repo-only — prefer workspace root for cross-repo features |

Never commit secrets (tokens, passwords). Redact in docs; reference env var names only.

## When to act

1. **New feature or bug** — create a new journal file (after confirming ticket id with user if unknown).
2. **Same session / follow-up** — append to the existing file under **Session log** (dated UTC).
3. **End of meaningful work** — update **Current state**, **Verification**, **Next steps**.

Ask once if ticket id is unclear: `AC-780` vs branch name vs PR only.

## File naming

```
anilworks/<TICKET>-<kebab-slug>.md
```

Examples: `AC-780-service-catalogue-stage-local.md`, `AIA-123-teams-markdown-replies.md`

Slug: lowercase, hyphens, ≤40 chars, no spaces.

## New file template

Create with this structure (fill what you know; leave placeholders only where still open):

```markdown
# <TICKET>: <title>

**Status:** in-progress | blocked | done (deploy pending) | done
**Repos:** applaud-serverless, applaud-ui-vue3, …
**Primary PRs:** #637, …
**Last updated:** YYYY-MM-DD (UTC)

## Goal

What the user wanted / acceptance in one short paragraph.

## What this feature is (domain)

Plain-language scope so future-you does not re-read entire decks.

## What we did

Bullet list of concrete actions (commits, deploys, curls, config), not vague "investigated".

## What we achieved

Outcomes: what works now, what was ruled out, proof (test names, curl shape, screenshots described).

## Architecture / boundaries

Layers (hub vs agent-tools-ui vs portal vs conversation-service). What owns what.

## Deploy & publish order

Numbered steps with **why** each step (only what applies to this ticket).

## Verification

Commands or checks (redact tokens). Expected pass/fail signals.

## Pitfalls we hit

Wrong paths taken once — so they are not repeated (detached HEAD, Node 24, entity filter, CSS CDN, etc.).

## Open / next

- [ ] …

## Session log

### YYYY-MM-DD

- …
```

## Updating an existing journal

1. Read the full file first.
2. Merge new facts; do not duplicate long prose.
3. Move superseded text to a one-line **Superseded:** note or delete if wrong.
4. Bump **Last updated** and **Status**.

## Agent behaviour

- At start of ticket work: `Glob anilworks/*<TICKET>*` or `Grep` ticket in `anilworks/`.
- If found: summarize **Current state** + **Next steps** to the user in 3–5 sentences, then continue the task.
- If not found: offer to create the journal from conversation so far.
- Do not create empty journals; need at least Goal + one Session log entry.

## Linking

- Link PRs: `https://github.com/ApplaudSolutions/<repo>/pull/<n>`
- Link in-repo paths with backticks only (no line numbers required in journal).
- Optional: `Related journals: AC-780-…` for split threads on same epic.

## README

Keep [anilworks/README.md](~/applaud/anilworks/README.md) as the index: add a table row when adding a new journal (ticket, title, status, one-line).
