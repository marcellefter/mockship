#!/usr/bin/env bash
# Sets up the sample app in the current directory for an eval run.
# Usage: scaffold.sh [base-overlay-dir|-] [branch-overlay-dir|-]
#   base overlay   — applied before the baseline commit (changes what the project "is");
#                    a .delete file in it lists paths to remove.
#   branch overlay — applied on the feature branch and committed (work already done).
set -eu
here=$(cd "$(dirname "$0")" && pwd)
base=${1:--}
branch=${2:--}

rsync -a --exclude node_modules --exclude dist "$here/sample-app/" .
if [ "$base" != "-" ]; then
  rsync -a --exclude .delete "$base/" .
  if [ -f "$base/.delete" ]; then
    while IFS= read -r path; do [ -n "$path" ] && rm -rf "$path"; done < "$base/.delete"
  fi
fi
git init -q -b main
git add -A
git -c user.name=eval -c user.email=eval@example.com commit -qm "Baseline"
git checkout -qb feature/work
if [ "$branch" != "-" ]; then
  rsync -a "$branch/" .
  git add -A
  git -c user.name=eval -c user.email=eval@example.com commit -qm "Work so far"
fi
if [ -z "${MOCKSHIP_SKIP_INSTALL:-}" ] && command -v npm >/dev/null 2>&1; then npm ci --silent --no-audit --no-fund >/dev/null 2>&1 || true; fi
