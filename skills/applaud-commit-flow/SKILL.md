---
name: applaud-commit-flow
description: Guides the user through Anil's Applaud branch/commit/push/PR workflow — when starting new work, offers to create a branch named type/BOARD-number (e.g. feat/AIA-123); when committing, asks for change type (fix/feat/bug), the board code (e.g. AIA) and issue number, a subject line, and a full description of what was fixed or implemented, then builds a properly formatted commit message, confirms with the user, and on approval syncs with main, commits, pushes, and opens or updates a pull request. Use this skill whenever the user wants to create a branch, commit, push, "submit", or open a PR for changes in applaud-serverless, applaud-ui, applaud-cloud, or any repo following the board-code/ticket-number convention — even if they just say "let's commit this" or "ready to push."
---

# Applaud Commit Flow

Turns a set of already-staged code changes into a correctly formatted commit, then pushes and opens/updates a PR — following Anil's fixed format so he never has to retype it by hand. Also handles creating a correctly named branch when starting new work.

## When to use this

Trigger any time the user wants to commit, push, or "submit" work in an Applaud repo (`applaud-serverless`, `applaud-ui`, `applaud-cloud`, or similar), or mentions an AIA board ticket in the context of finishing up changes. Don't wait for the exact word "commit" — "ready to push this", "let's wrap this up", "submit this" all count.

## Preconditions

First, check whether the user needs a new branch. Run `git branch --show-current` — if they're already on a branch that looks purpose-built for this work (not `main`/`master`/`develop`), just confirm that's the one to use rather than re-asking. If they're on `main`/`master`/`develop`, or otherwise say they're starting new work, offer to create a branch.

**Branch format:** `<type>/<BOARD>-<number>` (e.g. `feat/AIA-123`, `fix/AIA-456`) — same type/board/number the commit itself will use. Ask for these now if creating a branch (see the Type, Board code, and Issue number questions below — ask them here instead of later in that case, then reuse the same answers for the commit message so the user isn't asked twice). Create it off the latest default branch: `git fetch origin`, then `git checkout -b <type>/<BOARD>-<number> origin/<default-branch>`.

Staging is manual — the user stages files themselves, this skill never runs `git add`. Once on the right branch, run `git status` (and `git diff --staged --stat` for a quick summary) to confirm there's something staged.

- If nothing is staged: tell the user nothing is staged yet and stop. Don't proceed to the questions.
- If there are staged changes: briefly show the staged file list back to the user for a sanity check, then proceed.

## The question flow

Ask these in order, one at a time (don't dump all four at once — it reads like a form, and the answer to one can shape how you ask the next). Skip any of the first three that were already answered as part of branch creation above.

1. **Type** — "Is this a `fix`, `feat`, or `bug`?" (only these three; if the user says something else like "chore" or "refactor", ask them to pick the closest of the three, since that's what the format supports today)
2. **Board code** — "Which board — AIA, or something else?" Default to `AIA` if the user just says "same as usual" or doesn't answer, but always ask rather than assuming silently, since it can change per project.
3. **Issue number** — "What's the issue number?" Accept any of: a full URL, `AIA-123`, or just `123` — if the user's answer to this or the board question already contains both pieces (e.g. they just paste `AIA-456` or a full ticket URL), don't ask the other one again, just confirm you parsed it correctly. Normalize to `<BOARD>-<number>` for the commit. If they paste a full URL, keep the URL handy for the PR description but still use the short `<BOARD>-<number>` form in the commit line.
4. **Subject line** — "One-line summary for the commit subject?" Keep it short (~50-70 chars), imperative mood (e.g. "add retry logic to SF sync job", not "added" or "adds").
5. **Full description** — Prefer **detailed implementation detail** in the commit body and PR description for every ticket push (especially multi-ticket / scratch-map work like AC-780). Do not settle for a one-liner when the change is non-trivial.

   **Default for ticket pushes:** draft the body yourself from the diff and the issue/spec, then show it for confirmation. Include:
   - **What** — behaviour shipped (user-visible + API)
   - **How** — key modules, endpoints, types, provider/seams; naming constraints that matter
   - **Why / decisions** — non-obvious choices, out-of-scope deliberately left out
   - **Tests** — what was run or added
   - **Ticket** — scratch issue id / board link when known (e.g. issue 05)

   Still ask the user if they want to add or trim anything. If they dictate a short body themselves, use it; if they say "short is fine," don't pad. If they say nothing and the change is a ticket increment, draft the detailed body.

## Assembling the message

Commit format:

```
<type>(#<BOARD>-<number>): <subject line>

<full description>
```

Example:

```
fix(#AIA-123): resolve duplicate key error on Policy save

Root caused to a commented-out backend guard left over from the Vue 2 to 3
migration, which let two policies save with an empty _id. Restored the guard
and added a unit test covering the empty-id case.
```

For multi-commit feature branches that already have a PR, when pushing the next ticket: keep the commit body ticket-specific and detailed; when updating the PR body, either append a new `## Ticket NN` section with that same detail, or ask whether to leave the PR description unchanged and only push.

## Confirm before doing anything

Show the assembled commit message back to the user exactly as it will be committed (full detailed body included), and ask them to confirm — e.g. "Here's the commit — want me to go ahead and commit, push, and open/update the PR?" Do not commit, push, or touch GitHub until the user explicitly confirms. If they want changes, edit and re-show before proceeding — don't loop back through the whole question flow unless they ask for that.

## On confirmation — sync, commit, push, PR

Run these in order, checking the result of each before moving to the next:

1. `git commit -m "<type>(#<BOARD>-<number>): <subject>" -m "<full description>"`
2. **Sync with main before pushing**, so the PR doesn't go up stale or conflict-ridden:
   - Detect the default branch: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null` (falls back to checking for `main` then `master` if that's not set).
   - `git fetch origin`
   - `git rebase origin/<default-branch>` — rebase is the default approach here (keeps history clean for the PR), unless the user has said they prefer merge for this repo, in which case use `git merge origin/<default-branch>` instead.
   - If the rebase hits conflicts: stop, tell the user which files conflict, and let them resolve it (or tell you how) rather than guessing at a resolution yourself. Once resolved, continue with `git rebase --continue`. If it gets messy, offer `git rebase --abort` and falling back to a merge instead.
3. Push the current branch: `git push -u origin HEAD` (use `--force-with-lease` instead of a plain push if the branch was rebased and was already pushed before, since the history changed).
4. Open or update the PR:
   - Check if a PR already exists for this branch: `gh pr view --json url,number 2>/dev/null`
   - If none exists, create one: `gh pr create --title "<type>(#<BOARD>-<number>): <subject>" --body "<detailed implementation description>

Issue: <issue link if the user gave a full URL, otherwise <BOARD>-<number>>"`
     - If `gh` isn't authenticated or installed, fall back to giving the user the compare URL (`https://github.com/<org>/<repo>/compare/<base>...<branch>?expand=1`) so they can open the PR manually, and tell them the title/body to paste in.
   - If a PR already exists: **default to appending** a `## Ticket / commit` section with this push's detailed implementation notes (do not wipe prior ticket sections). Only skip the body update if the user explicitly says leave the PR description alone.
5. Report back: the commit hash, the branch pushed, and the PR URL (new or existing).

## Notes

- Never invent an issue number or board code, or skip either question, even if the user seems in a hurry — the format requires both and it's how these get triaged on the board.
- If the user is working across multiple Applaud repos in one session, confirm which repo/directory before running any git commands, since `applaud-serverless`, `applaud-ui`, and `applaud-cloud` are usually checked out side by side.
- Keep the tone efficient here — this is a workflow tool for someone who does this often, not a place for extra commentary once the format is understood.
- **Ticket pushes:** always include detailed implementation detail in the commit body and PR (What / How / decisions / tests). Thin bodies are the exception, not the default.
