# Cursor personal skills (Anil)

Portable copy of Agent Skills from `~/.cursor/skills/` for Applaud workflow and repo hygiene.

## Install on a new machine

```bash
git clone https://github.com/anil-kashipaka/cursor-personal-skills.git
mkdir -p ~/.cursor/skills
cp -r cursor-personal-skills/skills/* ~/.cursor/skills/
```

Restart Cursor (or start a new Agent chat) so skills are picked up.

## Tmux Applaud workspace

```bash
chmod +x ~/applaud/cursor-personal-skills/scripts/tmux-applaud-setup.sh
~/applaud/cursor-personal-skills/scripts/tmux-applaud-setup.sh
```

Creates session `applaud-workspace` with windows for each top-level repo under `~/applaud`, all `apps/*` except `analytics`, `docgen`, `letter-management`, and `voice`, and an allowlisted set of packages (see `scripts/tmux-applaud-setup.sh`). Missing paths are skipped. Override root with `PROJECTS_DIR=/path/to/applaud`.

Optional: symlink instead of copy so updates flow from a single clone:

```bash
ln -s ~/path/to/cursor-personal-skills/skills/* ~/.cursor/skills/
```

## Skills in this repo

| Directory | Purpose |
|-----------|---------|
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
cp -r ~/.cursor/skills/{applaud-commit-flow,pre-push-checks,setup-pre-commit,anilworks-context,ponytail} \
  ~/applaud/cursor-personal-skills/skills/
# Fix anilworks paths back to ~/applaud if you copied from live ~/.cursor/skills
cd ~/applaud/cursor-personal-skills && git add -A && git commit -m "Sync skills from laptop" && git push
```
