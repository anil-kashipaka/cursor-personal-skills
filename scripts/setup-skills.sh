#!/usr/bin/env bash
# Link this repo's skills into Cursor and OpenCode, and install the routing policy.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CURSOR_SKILLS="${CURSOR_SKILLS:-$HOME/.cursor/skills}"
OPENCODE_SKILLS="${OPENCODE_SKILLS:-$HOME/.config/opencode/skills}"
AGENTS_SKILLS="${AGENTS_SKILLS:-$HOME/.agents/skills}"
POLICY="$ROOT/skills/skill-routing/SKILL.md"

mkdir -p "$CURSOR_SKILLS" "$OPENCODE_SKILLS" "$AGENTS_SKILLS" "$HOME/.config/opencode"

link_skill() {
  local dest="$1/$name"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    rm -rf "$dest"
  fi
  ln -sfn "$skill_dir" "$dest"
}

for skill_dir in "$ROOT"/skills/*; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  link_skill "$CURSOR_SKILLS"
  link_skill "$OPENCODE_SKILLS"
  link_skill "$AGENTS_SKILLS"
done

# Drop YAML frontmatter and write the routing policy for OpenCode and the workspace parent.
write_policy() {
  awk 'BEGIN { front=0; started=0 } /^---$/ { front++; next } front >= 2 { if (!started && $0 == "") next; started=1; print }' "$POLICY" > "$1"
}
write_policy "$HOME/.config/opencode/AGENTS.md"

parent="$(cd "$ROOT/.." && pwd)"
if ! git -C "$parent" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  write_policy "$parent/AGENTS.md"
fi

echo "Linked skills from $ROOT/skills into:"
echo "  $CURSOR_SKILLS"
echo "  $OPENCODE_SKILLS"
echo "  $AGENTS_SKILLS"
