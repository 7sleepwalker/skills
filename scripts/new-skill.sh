#!/usr/bin/env bash
set -euo pipefail

# Scaffold and wire a new promoted skill: the deterministic half of make-skill.
# The productivity/make-skill skill runs the interview and drafts the SKILL.md
# body (judgment); this script does the mechanical wiring (determinism) that
# check-manifest.sh guards. See .agents/adr/0011-authoring-hybrid-skill-script.md.
#
# It creates skills/<bucket>/<name>/SKILL.md from a template, adds the skill to
# plugin.json skills[] and to both READMEs, then self-verifies by running
# link-skills.sh and check-manifest.sh.
#
# Usage:
#   scripts/new-skill.sh <bucket> <name> <invocation> "<description>"
#     bucket      engineering | productivity
#     name        kebab-case; becomes the directory and the frontmatter name
#     invocation  user | model
#     description one line, human- or model-facing (quote it)
#
# Env:
#   NS_SKIP_VERIFY=1   scaffold and wire only; skip link + check-manifest.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

die() { echo "new-skill: $*" >&2; exit 1; }

[ "$#" -eq 4 ] || die "usage: new-skill.sh <bucket> <name> <user|model> \"<description>\""
BUCKET="$1"; NAME="$2"; INV="$3"; DESC="$4"

case "$BUCKET" in engineering|productivity) ;; *) die "bucket must be engineering or productivity, got '$BUCKET'";; esac
case "$INV" in user|model) ;; *) die "invocation must be user or model, got '$INV'";; esac
printf '%s' "$NAME" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$' || die "name must be kebab-case, got '$NAME'"
[ -n "$DESC" ] || die "description must not be empty"

DIR="skills/$BUCKET/$NAME"
[ -e "$DIR" ] && die "$DIR already exists"

TITLE="$(printf '%s' "$NAME" | tr '-' ' ' | awk '{ $1=toupper(substr($1,1,1)) substr($1,2) } 1')"

mkdir -p "$DIR"

# --- SKILL.md from template ------------------------------------------------
{
  echo '---'
  echo "name: $NAME"
  echo "description: $DESC"
  [ "$INV" = "user" ] && echo 'disable-model-invocation: true'
  echo '---'
  echo
  echo "# $TITLE"
  echo
  echo "<!-- TODO(make-skill): replace this with the real body. Open with what the"
  echo "     skill does and when it applies, in two or three sentences, then the"
  echo "     steps. Name capabilities, not tools. See boo:writing-for-agents. -->"
  echo
  echo '**Plain language.** Write anything a person reads — questions, findings, summaries, reports — for a non-native English speaker: short sentences, one idea each, common words, no idioms or phrasal verbs. Keep technical terms and proper names exact (`null-check`, `race`) and never simplify code. Clear over clever.'
} > "$DIR/SKILL.md"

echo "created $DIR/SKILL.md"

# --- wire plugin.json + both READMEs (structured edits) --------------------
NS_BUCKET="$BUCKET" NS_NAME="$NAME" NS_DESC="$DESC" NS_INV="$INV" NS_REPO="$REPO" \
python3 - <<'PY'
import json, os

bucket = os.environ["NS_BUCKET"]
name   = os.environ["NS_NAME"]
desc   = os.environ["NS_DESC"].strip()
inv    = os.environ["NS_INV"]
repo   = os.environ["NS_REPO"]
if not desc.endswith("."):
    desc += "."
inv_hdr = "User-invoked" if inv == "user" else "Model-invoked"

# plugin.json: add the path, keep the list sorted, keep 2-space JSON.
pj = os.path.join(repo, ".claude-plugin/plugin.json")
with open(pj) as f:
    data = json.load(f)
path = f"./skills/{bucket}/{name}"
if path not in data["skills"]:
    data["skills"].append(path)
    data["skills"].sort()
with open(pj, "w") as f:
    f.write(json.dumps(data, indent=2) + "\n")
print(f"wired {path} into plugin.json")

def is_bullet(line):
    return line.lstrip().startswith("- ")

def is_header(line):
    s = line.strip()
    return s.startswith("### ") or s.startswith("## ") or (s.startswith("**") and s.endswith("**"))

def insert_bullet(md_path, bullet, section_title=None):
    with open(md_path) as f:
        lines = f.read().split("\n")
    i = 0
    if section_title:
        while i < len(lines) and not (
            lines[i].startswith("### ") and section_title.lower() in lines[i].lower()
        ):
            i += 1
        if i >= len(lines):
            raise SystemExit(f"section '{section_title}' not found in {md_path}")
        i += 1
    # find the invocation sub-header
    while i < len(lines) and not (is_header(lines[i]) and inv_hdr in lines[i]):
        i += 1
    if i >= len(lines):
        raise SystemExit(f"sub-header '{inv_hdr}' not found in {md_path}")
    # insertion point: after the last bullet in this block
    j = i + 1
    last = None
    while j < len(lines):
        if is_header(lines[j]):
            break
        if is_bullet(lines[j]):
            last = j
        j += 1
    ins = (last + 1) if last is not None else i + 1
    lines.insert(ins, bullet)
    with open(md_path, "w") as f:
        f.write("\n".join(lines))
    print(f"wired bullet into {md_path}")

# root README: scope to the bucket section (### Engineering / ### Productivity)
insert_bullet(
    os.path.join(repo, "README.md"),
    f"- **[boo:{name}](./skills/{bucket}/{name}/SKILL.md)**: {desc}",
    section_title=bucket.capitalize(),
)
# bucket README: whole file is that bucket
insert_bullet(
    os.path.join(repo, f"skills/{bucket}/README.md"),
    f"- **[boo:{name}](./{name}/SKILL.md)**: {desc}",
)
PY

# --- self-verify -----------------------------------------------------------
if [ "${NS_SKIP_VERIFY:-0}" = "1" ]; then
  echo "new-skill: NS_SKIP_VERIFY set, skipping link + check-manifest"
  exit 0
fi

echo "new-skill: linking + verifying"
bash "$REPO/scripts/link-skills.sh"
bash "$REPO/scripts/check-manifest.sh"
