#!/usr/bin/env bash
set -euo pipefail

# Links this repo into ~/.claude/skills as a single skills-directory plugin, so
# every promoted skill is reachable as /boo:<name> and an edit here is live in
# the next session with no install step.
#
# Private skills are absent from plugin.json's skills[], so they get their own
# bare symlinks and stay outside the boo: namespace.
#
# It also links every skill (bare, one per directory) into ~/.agents/skills, the
# generic cross-agent skills dir, so agents that read it load the same skills.
# The bodies are agent-agnostic (ADR-0009); the links keep one source of truth.
#
# Re-run after adding or renaming a skill. See .agents/adr/0005-boo-namespace.md
# and .agents/adr/0010-cross-agent-distribution.md.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
PLUGIN_NAME="boo"

# Enable the tracked git hooks (pre-push runs check-manifest). Harmless to
# re-run; only applies when this is a git clone. See adr/0008-pre-push-hook.md.
if git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$REPO" config core.hooksPath .githooks
  echo "git hooks enabled (core.hooksPath -> .githooks)"
fi

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

# --- Generic cross-agent dir: one bare link per skill (promoted + private), so
# --- agents that read ~/.agents/skills load them too. No boo: namespace here.
# --- See .agents/adr/0010-cross-agent-distribution.md.
AGENTS_DEST="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"

if [ -L "$AGENTS_DEST" ]; then
  aresolved="$(cd "$(dirname "$AGENTS_DEST")" && cd "$(readlink "$AGENTS_DEST")" && pwd)"
  case "$aresolved" in
    "$REPO" | "$REPO"/*)
      echo "error: $AGENTS_DEST is a symlink into this repo ($aresolved)." >&2
      echo "Remove it (rm \"$AGENTS_DEST\") and re-run." >&2
      exit 1
      ;;
  esac
fi

mkdir -p "$AGENTS_DEST"

acleaned=0
for entry in "$AGENTS_DEST"/*; do
  [ -L "$entry" ] || continue
  case "$(readlink "$entry")" in
    "$REPO" | "$REPO"/*) rm "$entry"; acleaned=$((acleaned + 1)) ;;
  esac
done
[ "$acleaned" -eq 0 ] || echo "cleaned $acleaned stale link(s) in $AGENTS_DEST"

alinked=0
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  if [ -e "$AGENTS_DEST/$name" ] && [ ! -L "$AGENTS_DEST/$name" ]; then
    echo "replacing real directory $AGENTS_DEST/$name"
    rm -rf "${AGENTS_DEST:?}/$name"
  fi
  ln -sfn "$src" "$AGENTS_DEST/$name"
  alinked=$((alinked + 1))
done < <(find "$REPO/skills" -name SKILL.md -print0 | sort -z)

echo "$alinked skill(s) linked into $AGENTS_DEST (generic cross-agent dir)"
