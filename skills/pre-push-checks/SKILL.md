---
name: pre-push-checks
description: Runs format, lint, type-check, and tests on edited files before a commit or push. Use when the user is about to push, open or update a pull request, or says "push", "submit", or "ready to push" — including inside the Applaud commit flow, before git push. When the user says push, run lint on the edited files only.
---

# Pre-push checks

When the user says push, run lint on the edited files only.

Run these checks on the files that will be pushed. Do not push, and do not open or update a PR, until they pass. If the Applaud commit flow is also in play, run this skill before `git commit` / `git push`.

Do not skip the checks. Do not pass `--no-verify` unless the user explicitly asks for that in the same turn.

Before every push, take the latest default branch. `git fetch origin`, then `git rebase origin/main` (or `origin/master` when that is the default). If the rebase conflicts, stop and report the files. If the branch was already pushed, update it with `--force-with-lease`, never a plain `--force`, and never force-push `main`.

## 1. Edited files

Collect the set that this push will contain:

- Unstaged, staged, and untracked files from `git status --short`
- Committed files not yet on the remote: `git diff --name-only @{upstream}...HEAD` when an upstream exists, otherwise `git diff --name-only origin/HEAD...HEAD`

Ignore files that are not source (lockfiles, generated `dist/`, images) unless the user is pushing only those.

Group the remaining paths by package: the nearest directory that has its own `package.json` (for example `packages/agent-tools-ui`). Repo-root files stay at the root.

## 2. Format

From the repo root, format only the edited files Prettier can handle (`.js`, `.ts`, `.vue`, `.json`, `.md`, `.css`, `.yml`):

```bash
npx prettier --write <files>
```

If Prettier rewrites a file, keep that rewrite in the commit. Do not format the whole repo.

## 3. Lint

When the user says push, run lint on the edited files only. Do not run `eslint .`, `npm run lint`, or `npm run lint:check` as the push check. Those lint the whole repo.

From the repo root, when ESLint is configured at the root:

```bash
npx eslint <files>
```

When a package owns the ESLint config, run ESLint on the edited paths from that package. Do not invoke the package `lint` script if it lints the whole package. Fix lint errors in the edited files before continuing. Do not add `eslint-disable` to silence a new violation.

## 4. Type-check

`tsc` cannot be limited to a file list. For each package that owns an edited file, run its type-check script if it has one:

```bash
npm run type-check --workspace=<package-name>
```

If the package has no `type-check` script, use the repo script that covers it (`npm run type-check` only when the edited files are not inside a workspace). A failure in an untouched package is still a failure if that command type-checks it — fix it when it is caused by the edit; otherwise say which command failed and what was out of scope.

## 5. Tests

Run the narrowest tests that cover the edited files.

- An edited `*.test.ts` / `*.spec.ts`: run that file with the package's Vitest (or Jest) config.
- An edited source file: run the test file that imports it when one is obvious; otherwise run the package test script (`npm run test --workspace=<package-name>`).
- Do not run the whole monorepo suite unless the edit is at the repo root and no package test script applies.

A suite that fails to load (for example a `.css` import under Vitest) is a failed check. Fix the harness or the import before pushing.

## 6. Stop or continue

| Result | What to do |
|--------|------------|
| All four passed | Tell the user the commands and that they passed, then continue the commit or push they asked for. |
| Any failed | Stop. Name the command, the package, and the first error. Do not push. |

Re-run only the checks that failed after a fix, plus format if the fix changed formatting.
