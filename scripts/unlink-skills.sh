#!/usr/bin/env bash
set -euo pipefail

# Removes only the symlinks in ~/.claude/skills that point into this repo.
# Anything else there is left alone.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

if [ -d "$DEST" ]; then
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
else
  echo "$DEST does not exist, no symlinks to remove"
fi

# Symmetry with link-skills.sh: turn the tracked git hooks back off, but only if
# core.hooksPath still points at our .githooks (never clobber a custom value).
if git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 &&
   [ "$(git -C "$REPO" config --get core.hooksPath 2>/dev/null)" = ".githooks" ]; then
  git -C "$REPO" config --unset core.hooksPath
  echo "git hooks disabled (core.hooksPath unset)"
fi
