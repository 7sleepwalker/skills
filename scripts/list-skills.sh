#!/usr/bin/env bash
set -euo pipefail

# One line per skill: bucket, name, invocation mode.

REPO="$(cd "$(dirname "$0")/.." && pwd)"

printf '%-12s  %-24s  %s\n' BUCKET NAME INVOCATION
while IFS= read -r -d '' skill_md; do
  dir="$(dirname "$skill_md")"
  name="$(basename "$dir")"
  bucket="$(basename "$(dirname "$dir")")"
  if grep -qE '^disable-model-invocation:[[:space:]]*true[[:space:]]*$' "$skill_md"; then
    mode="user-invoked"
  else
    mode="model-invoked"
  fi
  printf '%-12s  %-24s  %s\n' "$bucket" "$name" "$mode"
done < <(find "$REPO/skills" -name SKILL.md -print0 | sort -z)
