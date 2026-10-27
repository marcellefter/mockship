#!/usr/bin/env bash
# Lists every file changed on this branch (committed, staged, unstaged, untracked) that is
# neither inside the mock's feature folder nor named as a touchpoint in its MOCK.md.
# Usage: check-boundary.sh <feature-folder> [base-ref]
set -euo pipefail

feature=${1:?usage: check-boundary.sh <feature-folder> [base-ref]}
[ -d "$feature" ] || { echo "error: $feature is not a directory" >&2; exit 2; }
feature_abs=$(cd "$feature" && pwd -P)
top=$(cd "$(git -C "$feature_abs" rev-parse --show-toplevel)" && pwd -P)
rel=${feature_abs#"$top"/}
mock_md="$feature_abs/MOCK.md"
[ -f "$mock_md" ] || { echo "error: no MOCK.md in $feature" >&2; exit 2; }
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
fi
[ -n "$base" ] || { echo "error: no base branch found; pass one: check-boundary.sh $feature <base-ref>" >&2; exit 2; }
merge_base=$(git merge-base "$base" HEAD)

inside=0
listed=0
unlisted=()
while IFS= read -r file; do
  [ -n "$file" ] || continue
  if [[ "$file" == "$rel"/* ]]; then
    inside=$((inside + 1))
  elif grep -qF "\`$file\`" "$mock_md"; then
    listed=$((listed + 1))
  else
    unlisted+=("$file")
  fi
done < <( { git diff --name-only "$merge_base"; git ls-files --others --exclude-standard; } | sort -u)

echo "base: $base ($merge_base)"
echo "inside $rel: $inside file(s); touchpoints listed in MOCK.md: $listed file(s)"
if [ ${#unlisted[@]} -gt 0 ]; then
  echo "FAIL: changed outside the feature folder and not listed (as \`path\`) in MOCK.md:"
  printf '  %s\n' "${unlisted[@]}"
  exit 1
fi
echo "OK"
