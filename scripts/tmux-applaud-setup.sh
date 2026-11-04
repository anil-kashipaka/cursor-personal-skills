#!/usr/bin/env bash
# Applaud dev tmux layout: one window per workspace root, app, and package.
# Paths assume clones live under ~/applaud (override with PROJECTS_DIR).

set -euo pipefail

SESSION_NAME="${SESSION_NAME:-applaud-workspace}"
PROJECTS_DIR="${PROJECTS_DIR:-$HOME/applaud}"
SL="$PROJECTS_DIR/applaud-serverless"

tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true

new_win() {
  local name="$1"
  local dir="$2"
  local node_version="${3:-}"

  if [[ ! -d "$dir" ]]; then
    echo "skip (missing): $name -> $dir" >&2
    return 0
  fi

  if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME" -n "$name" -c "$dir"
  else
    tmux new-window -t "$SESSION_NAME" -n "$name" -c "$dir"
  fi
  sleep 0.3
  if [[ -n "$node_version" ]] && command -v nvm >/dev/null 2>&1; then
    tmux send-keys -t "$SESSION_NAME:$name" "nvm use $node_version" Enter
  elif [[ -n "$node_version" ]]; then
    tmux send-keys -t "$SESSION_NAME:$name" "# nvm use $node_version  # install nvm if needed" Enter
  fi
}

# --- Top-level repos (matches multi-root work under ~/applaud) ---
new_win "ui" "$PROJECTS_DIR/applaud-ui-vue3" 22
new_win "serverless" "$SL" 24
new_win "cloud" "$PROJECTS_DIR/applaud-cloud" 18
new_win "anilworks" "$PROJECTS_DIR/anilworks" ""
new_win "native" "$PROJECTS_DIR/Applaud-native" 22
new_win "loopback-mongo" "$PROJECTS_DIR/loopback-connector-mongodb" 22
new_win "skills" "$PROJECTS_DIR/cursor-personal-skills" ""

# --- applaud-serverless apps & packages (all dirs on disk) ---
if [[ -d "$SL/apps" ]]; then
  while IFS= read -r app; do
    [[ -n "$app" ]] || continue
    new_win "$app" "$SL/apps/$app" 24
  done < <(find "$SL/apps" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort)
fi

if [[ -d "$SL/packages" ]]; then
  while IFS= read -r pkg; do
    [[ -n "$pkg" ]] || continue
    # Avoid duplicate window name if same as an app (unlikely)
    new_win "$pkg" "$SL/packages/$pkg" 24
  done < <(find "$SL/packages" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort)
fi

tmux select-window -t "$SESSION_NAME:ui"
tmux attach-session -t "$SESSION_NAME"
