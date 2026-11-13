# Cursor personal skills (Anil)

Portable copy of Agent Skills from `~/.cursor/skills/` for Applaud workflow and repo hygiene.

## Install on a new machine

```bash
git clone https://github.com/anil-kashipaka/cursor-personal-skills.git
chmod +x cursor-personal-skills/scripts/setup-skills.sh
cursor-personal-skills/scripts/setup-skills.sh
```

That links every skill in this repo into `~/.cursor/skills/`, `~/.config/opencode/skills/`, and `~/.agents/skills/`, and writes the routing policy to `~/.config/opencode/AGENTS.md` and the parent workspace `AGENTS.md` when that parent is not a git repo.

Restart Cursor (or start a new Agent chat) so skills are picked up.

## Tmux Applaud workspace

```bash
chmod +x ~/applaud/cursor-personal-skills/scripts/tmux-applaud-setup.sh
~/applaud/cursor-personal-skills/scripts/tmux-applaud-setup.sh
```

Creates session `applaud-workspace` with windows for each top-level repo under `~/applaud`, all `apps/*` except `analytics`, `docgen`, `letter-management`, and `voice`, and an allowlisted set of packages (see `scripts/tmux-applaud-setup.sh`). Missing paths are skipped. Override root with `PROJECTS_DIR=/path/to/applaud`.

## Skills in this repo

| Directory | Purpose |
|-----------|---------|
| `skill-routing` | Chooses `how`, `blast-radius`, `grill-with-docs`, `to-spec`, `tdd`, `improve-codebase-architecture`, `interrogate`, and `unslop` from the task |
| `how` | Explain how a subsystem works |
| `blast-radius` | Check what a change can break before editing it |
| `grill-with-docs` | Interview a vague plan and write the docs as you go |
| `to-spec` | Turn the current discussion into a spec |
| `tdd` | Test-first implementation and bug fixes |
| `improve-codebase-architecture` | Find and work through a structural cleanup |
| `interrogate` | Adversarial review of a change |
| `unslop` | Remove AI tells from writing |
| `applaud-commit-flow` | Branch naming, commit message format, rebase, push, `gh pr` |
| `pre-push-checks` | Format/lint/type-check/tests on edited files before push |
| `setup-pre-commit` | Husky + lint-staged + Prettier + typecheck/test hook |
| `anilworks-context` | Ticket journals under `~/applaud/anilworks/` |
| `ponytail` | Lazy senior dev mode — simplest solution that works |

## Anilworks journals (separate from skills)

The **anilworks-context** skill expects work notes at:

```text
~/applaud/anilworks/
```

Create that folder and copy your journals from the old laptop (or use `anilworks/README.template.md` as a starter). Do not commit tokens in journal files.

## Cursor skill locations (reference)

| Location | What |
|----------|------|
| `~/.cursor/skills/` | Your personal skills (this repo installs here) |
| `~/.cursor/skills-cursor/` | Cursor built-ins — do not edit |
| `.cursor/skills/` in a repo | Project-scoped skills (optional) |

Each skill is a folder with `SKILL.md` (YAML frontmatter + markdown body). See [Cursor create-skill docs](https://cursor.com/docs) or Cursor’s built-in `create-skill` skill.

## Updating this repo from your machine

After editing skills under `~/.cursor/skills/`:

```bash
cp -r ~/.cursor/skills/{skill-routing,how,blast-radius,grill-with-docs,to-spec,tdd,improve-codebase-architecture,interrogate,unslop,applaud-commit-flow,pre-push-checks,setup-pre-commit,anilworks-context,ponytail} \
  ~/applaud/cursor-personal-skills/skills/
# Fix anilworks paths back to ~/applaud if you copied from live ~/.cursor/skills
cd ~/applaud/cursor-personal-skills && git add -A && git commit -m "Sync skills from laptop" && git push
```
