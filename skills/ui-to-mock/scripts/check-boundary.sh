#!/usr/bin/env bash
# Lists every file changed on this branch (committed, staged, unstaged, untracked) that is
# neither inside the mock's feature folder nor listed under "## Touchpoints" in its MOCK.md.
#
# A touchpoint is a backticked path; one ending in "/" covers everything under that folder
# (route folders in file-based routers). Files of another mock in flight — inside another
# folder with its own MOCK.md, or listed as one of its touchpoints — are reported, not failed.
#
# Usage: check-boundary.sh <feature-folder> [base-ref]
#   base-ref  the branch or commit the mock started from. Required when you are on the base
#             branch itself, where committed mock files cannot be told apart from history.
# Exit codes: 0 OK, 1 files outside the boundary, 2 usage or git error.
set -euo pipefail
# No temp files or here-strings, so a sandbox that blocks them cannot make the check pass.

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
  current=$(git symbolic-ref -q --short HEAD || true)
  if [ -n "$current" ] && [ "$current" = "${base#origin/}" ]; then
    die "you are on the base branch ($current), where committed mock files look like history; pass the commit the mock started from: check-boundary.sh $feature <commit>"
  fi
fi
git rev-parse -q --verify "$base^{commit}" >/dev/null || die "base ref '$base' not found"
merge_base=$(git merge-base "$base" HEAD) || die "no merge base between $base and HEAD"

changed=$(git -c core.quotePath=false diff --name-only "$merge_base") || die "git diff failed"
untracked=$(git -c core.quotePath=false ls-files --others --exclude-standard) || die "git ls-files failed"
all_files=$(printf '%s\n%s\n' "$changed" "$untracked" | sort -u)

touchpoints_of() { # backticked paths under "## Touchpoints" in the given MOCK.md
  awk '/^## /{ inside = ($0 ~ /^## Touchpoints/) } inside' "$1" | grep -oE '`[^`]+`' | tr -d '`' || true
}
covered_by() { # covered_by <file> <newline-separated touchpoints>
  local file=$1 point
  while IFS= read -r point; do
    [ -n "$point" ] || continue
    if [ "$file" = "$point" ]; then return 0; fi
    case "$point" in */) [[ "$file" == "$point"* ]] && return 0 ;; esac
  done < <(printf '%s\n' "$2")
  return 1
}

own_points=$(touchpoints_of "$mock_md")
other_dirs=()
other_points=""
while IFS= read -r file; do
  case "$file" in
    */MOCK.md)
      dir=${file%/MOCK.md}
      if [ "$dir" != "$rel" ] && [ -f "$dir/MOCK.md" ]; then
        other_dirs+=("$dir")
        other_points+=$(touchpoints_of "$dir/MOCK.md")$'\n'
      fi
      ;;
  esac
done < <(printf '%s\n' "$all_files")

inside=0
listed=0
other=0
unlisted=()
while IFS= read -r file; do
  [ -n "$file" ] || continue
  if [[ "$file" == "$rel"/* ]]; then
    inside=$((inside + 1))
  elif covered_by "$file" "$own_points"; then
    listed=$((listed + 1))
  else
    in_other=0
    for dir in ${other_dirs[@]+"${other_dirs[@]}"}; do
      [[ "$file" == "$dir"/* ]] && in_other=1
    done
    if [ "$in_other" = 1 ] || covered_by "$file" "$other_points"; then
      other=$((other + 1))
    else
      unlisted+=("$file")
    fi
  fi
done < <(printf '%s\n' "$all_files")

echo "base: $base ($merge_base)"
echo "inside $rel: $inside file(s); touchpoints listed in MOCK.md: $listed file(s)"
if [ ${#other_dirs[@]} -gt 0 ]; then
  echo "other mocks in flight (${other_dirs[*]}): $other file(s), not checked here"
fi
if [ ${#unlisted[@]} -gt 0 ]; then
  echo "FAIL: changed outside the feature folder and not listed (as \`path\` or \`folder/\`) under ## Touchpoints in MOCK.md:"
  printf '  %s\n' "${unlisted[@]}"
  exit 1
fi
echo "OK"
