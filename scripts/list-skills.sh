#!/usr/bin/env bash
set -euo pipefail

# One line per skill: bucket, name, invocation mode, and a trimmed description.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESC_MAX=70

printf '%-12s  %-20s  %-13s  %s\n' BUCKET NAME INVOCATION DESCRIPTION
while IFS= read -r -d '' skill_md; do
  dir="$(dirname "$skill_md")"
  name="$(basename "$dir")"
  bucket="$(basename "$(dirname "$dir")")"
  if grep -qE '^disable-model-invocation:[[:space:]]*true[[:space:]]*$' "$skill_md"; then
    mode="user-invoked"
  else
    mode="model-invoked"
  fi
  desc="$(sed -n 's/^description:[[:space:]]*//p' "$skill_md" | head -1)"
  desc="${desc%\"}"; desc="${desc#\"}"   # strip surrounding quotes, if any
  [ "${#desc}" -le "$DESC_MAX" ] || desc="${desc:0:$DESC_MAX}…"
  printf '%-12s  %-20s  %-13s  %s\n' "$bucket" "$name" "$mode" "$desc"
done < <(find "$REPO/skills" -name SKILL.md -print0 | sort -z)
