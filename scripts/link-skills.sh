#!/usr/bin/env bash
set -euo pipefail

# Links this repo into ~/.claude/skills as a single skills-directory plugin, so
# every promoted skill is reachable as /boo:<name> and an edit here is live in
# the next session with no install step.
#
# Private skills are absent from plugin.json's skills[], so they get their own
# bare symlinks and stay outside the boo: namespace.
#
# Re-run after adding or renaming a skill. See .agents/adr/0005-boo-namespace.md.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
PLUGIN_NAME="boo"

# If $DEST is itself a symlink into this repo, the links below would be written
# back into the repo's own tree. Bail out instead.
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

# Self-clean: drop every existing link into this repo, including the per-skill
# bare links this script used to create before the boo: namespace.
cleaned=0
for entry in "$DEST"/*; do
  [ -L "$entry" ] || continue
  target="$(readlink "$entry")"
  case "$target" in
    "$REPO" | "$REPO"/*)
      rm "$entry"
      cleaned=$((cleaned + 1))
      ;;
  esac
done
[ "$cleaned" -eq 0 ] || echo "cleaned $cleaned stale link(s)"

# A real directory of the same name is a pre-repo copy. Replace it.
if [ -e "$DEST/$PLUGIN_NAME" ] && [ ! -L "$DEST/$PLUGIN_NAME" ]; then
  echo "replacing real directory $DEST/$PLUGIN_NAME"
  rm -rf "${DEST:?}/$PLUGIN_NAME"
fi

ln -sfn "$REPO" "$DEST/$PLUGIN_NAME"
echo "linked $PLUGIN_NAME -> $REPO"

# Private skills: bare links, one per skill, outside the namespace.
private=0
if [ -d "$REPO/skills/private" ]; then
  while IFS= read -r -d '' skill_md; do
    src="$(dirname "$skill_md")"
    name="$(basename "$src")"

    if [ -e "$DEST/$name" ] && [ ! -L "$DEST/$name" ]; then
      echo "replacing real directory $DEST/$name"
      rm -rf "${DEST:?}/$name"
    fi

    ln -sfn "$src" "$DEST/$name"
    echo "linked $name -> $src (private)"
    private=$((private + 1))
  done < <(find "$REPO/skills/private" -name SKILL.md -print0 | sort -z)
fi

echo "$PLUGIN_NAME plugin linked, $private private skill(s) linked into $DEST"
echo "Restart Claude Code, then /boo: to list the namespaced skills."
