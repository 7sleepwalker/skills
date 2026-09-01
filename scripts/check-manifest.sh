#!/usr/bin/env bash
set -uo pipefail

# Verifies that the filesystem, the READMEs, and the plugin manifest agree,
# that every SKILL.md is well formed, and that nothing private leaked into a
# tracked file. Exits non-zero on the first category of problem found.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

PLUGIN=".claude-plugin/plugin.json"
ROOT_README="README.md"
PROMOTED_BUCKETS=(engineering productivity)

fail=0
err() { echo "FAIL: $*" >&2; fail=1; }

# --- every SKILL.md is well formed -----------------------------------------
while IFS= read -r -d '' skill_md; do
  dir="$(dirname "$skill_md")"
  name="$(basename "$dir")"

  head -1 "$skill_md" | grep -qx -- '---' \
    || { err "$skill_md has no frontmatter"; continue; }

  fm="$(awk 'NR>1 && /^---[[:space:]]*$/ {exit} NR>1 {print}' "$skill_md")"

  fm_name="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
  [ -n "$fm_name" ] || err "$skill_md frontmatter has no name"
  [ "$fm_name" = "$name" ] || err "$skill_md name '$fm_name' does not match directory '$name'"

  printf '%s\n' "$fm" | grep -q '^description:[[:space:]]*[^[:space:]]' \
    || err "$skill_md frontmatter has no description"

  printf '%s\n' "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$' \
    || err "$skill_md directory '$name' is not kebab-case"
done < <(find skills -name SKILL.md -print0)

# --- promoted skills are listed everywhere ---------------------------------
for bucket in "${PROMOTED_BUCKETS[@]}"; do
  [ -d "skills/$bucket" ] || continue
  bucket_readme="skills/$bucket/README.md"
  [ -f "$bucket_readme" ] || err "missing $bucket_readme"

  for dir in skills/"$bucket"/*/; do
    [ -f "$dir/SKILL.md" ] || continue
    name="$(basename "$dir")"
    grep -qF "\"./skills/$bucket/$name\"" "$PLUGIN" \
      || err "$name is not in $PLUGIN skills[]"
    grep -qF "$name" "$ROOT_README" \
      || err "$name is not referenced in $ROOT_README"
    [ -f "$bucket_readme" ] && { grep -qF "$name" "$bucket_readme" \
      || err "$name is not referenced in $bucket_readme"; }

    # plain-language output clause (ADR-0006): marker present, wording intact
    grep -qF '**Plain language.**' "$dir/SKILL.md" \
      || err "$name is missing the **Plain language.** clause (ADR-0006)"
    grep -qF 'for a non-native English speaker: short sentences' "$dir/SKILL.md" \
      || err "$name plain-language clause looks altered — expected the canonical wording (ADR-0006)"
  done
done

# --- plugin manifest points at real directories ----------------------------
while IFS= read -r path; do
  [ -f "$path/SKILL.md" ] || err "$PLUGIN lists $path, which has no SKILL.md"
  case "$path" in
    ./skills/private/*) err "$PLUGIN lists a private skill: $path" ;;
  esac
done < <(sed -n 's|^[[:space:]]*"\(\./skills/[^"]*\)".*|\1|p' "$PLUGIN")

# --- nothing private is referenced from a tracked file ---------------------
if git rev-parse --git-dir >/dev/null 2>&1; then
  leaks="$(git grep -In 'skills/private/[a-z]' -- . ':!.gitignore' ':!scripts' ':!.agents' ':!AGENTS.md' 2>/dev/null)"
  [ -z "$leaks" ] || { echo "$leaks" >&2; err "private skills referenced from tracked files (above)"; }
fi

# --- plugin CLI validation, when available ---------------------------------
if command -v claude >/dev/null 2>&1; then
  claude plugin validate . --strict || err "claude plugin validate failed"
else
  echo "note: claude CLI not found, skipped plugin validate"
fi

[ "$fail" -eq 0 ] && echo "check-manifest: OK"
exit "$fail"
