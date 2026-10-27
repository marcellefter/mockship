#!/usr/bin/env bash
# Lists every file changed on this branch (committed, staged, unstaged, untracked) that is
# neither inside the mock's feature folder nor listed under "## Touchpoints" in its MOCK.md.
# Usage: check-boundary.sh <feature-folder> [base-ref]
# Exit codes: 0 OK, 1 files outside the boundary, 2 usage or git error.
set -euo pipefail

die() { echo "error: $*" >&2; exit 2; }

feature=${1:-}
[ -n "$feature" ] || die "usage: check-boundary.sh <feature-folder> [base-ref]"
[ -d "$feature" ] || die "$feature is not a directory"
feature_abs=$(cd "$feature" && pwd -P)
git_top=$(git -C "$feature_abs" rev-parse --show-toplevel 2>/dev/null) || die "$feature is not inside a git repository"
top=$(cd "$git_top" && pwd -P)
rel=${feature_abs#"$top"/}
mock_md="$feature_abs/MOCK.md"
[ -f "$mock_md" ] || die "no MOCK.md in $feature"
cd "$top"

base=${2:-}
if [ -z "$base" ]; then
  for ref in "$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || true)" \
             origin/main origin/master main master; do
    if [ -n "$ref" ] && git rev-parse -q --verify "$ref^{commit}" >/dev/null; then
      base=$ref
      break
    fi
  done
  [ -n "$base" ] || die "no base branch found; pass one: check-boundary.sh $feature <base-ref>"
fi
git rev-parse -q --verify "$base^{commit}" >/dev/null || die "base ref '$base' not found"
merge_base=$(git merge-base "$base" HEAD) || die "no merge base between $base and HEAD"

changed=$(git -c core.quotePath=false diff --name-only "$merge_base") || die "git diff failed"
untracked=$(git -c core.quotePath=false ls-files --others --exclude-standard) || die "git ls-files failed"
touchpoints=$(awk '/^## /{ inside = ($0 ~ /^## Touchpoints/) } inside' "$mock_md")

inside=0
listed=0
unlisted=()
while IFS= read -r file; do
  [ -n "$file" ] || continue
  if [[ "$file" == "$rel"/* ]]; then
    inside=$((inside + 1))
  elif grep -qF "\`$file\`" <<<"$touchpoints"; then
    listed=$((listed + 1))
  else
    unlisted+=("$file")
  fi
done < <(printf '%s\n%s\n' "$changed" "$untracked" | sort -u)

echo "base: $base ($merge_base)"
echo "inside $rel: $inside file(s); touchpoints listed in MOCK.md: $listed file(s)"
if [ ${#unlisted[@]} -gt 0 ]; then
  echo "FAIL: changed outside the feature folder and not listed (as \`path\`) under ## Touchpoints in MOCK.md:"
  printf '  %s\n' "${unlisted[@]}"
  exit 1
fi
echo "OK"
