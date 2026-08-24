#!/usr/bin/env bash
set -euo pipefail

# Links every skill in this repo into ~/.claude/skills as a symlink, so an edit
# here is live in the next session with no install step. Private skills are
# linked too. Re-run after adding or renaming a skill.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

# If $DEST is itself a symlink into this repo, the per-skill links below would
# be written back into the repo's own tree. Bail out instead.
if [ -L "$DEST" ]; then
  resolved="$(cd "$(dirname "$DEST")" && cd "$(readlink "$DEST")" && pwd)"
  case "$resolved" in
    "$REPO" | "$REPO"/*)
      echo "error: $DEST is a symlink into this repo ($resolved)." >&2
      echo "Remove it (rm \"$DEST\") and re-run; this script will recreate it as a real directory." >&2
      exit 1
      ;;
  esac
fi

mkdir -p "$DEST"

linked=0
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$DEST/$name"

  # A real directory of the same name is a pre-repo copy. Replace it.
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "replacing real directory $target"
    rm -rf "$target"
  fi

  ln -sfn "$src" "$target"
  echo "linked $name -> $src"
  linked=$((linked + 1))
done < <(find "$REPO/skills" -name SKILL.md -print0 | sort -z)

echo "$linked skill(s) linked into $DEST"
