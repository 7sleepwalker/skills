#!/usr/bin/env bash
set -euo pipefail

# Removes only the symlinks in ~/.claude/skills that point into this repo.
# Anything else there is left alone.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

[ -d "$DEST" ] || { echo "$DEST does not exist, nothing to do"; exit 0; }

removed=0
for entry in "$DEST"/*; do
  [ -L "$entry" ] || continue
  target="$(readlink "$entry")"
  case "$target" in
    "$REPO" | "$REPO"/*)
      rm "$entry"
      echo "unlinked $(basename "$entry")"
      removed=$((removed + 1))
      ;;
  esac
done

echo "$removed symlink(s) removed from $DEST"
