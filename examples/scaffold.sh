#!/usr/bin/env bash
# Sets up the sample app in the current directory for an eval run.
# Usage: scaffold.sh [base-overlay|-] [branch-overlay ...]
#   base overlay    — applied before the baseline commit (changes what the project "is");
#                     a .delete file in it lists relative paths to remove.
#   branch overlays — applied in order on the feature branch and committed together
#                     (work already done); later overlays override earlier ones.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
base=${1:--}
[ $# -gt 0 ] && shift

rsync -a --exclude node_modules --exclude dist "$here/sample-app/" .
if [ "$base" != "-" ]; then
  rsync -a --exclude .delete "$base/" .
  if [ -f "$base/.delete" ]; then
    while IFS= read -r path; do
      [ -n "$path" ] || continue
      case "$path" in
        /* | *..*) echo "scaffold: refusing to delete '$path' (must be relative, without ..)" >&2; exit 1 ;;
      esac
      rm -rf "./$path"
    done < "$base/.delete"
  fi
fi
git init -q -b main
git add -A
git -c user.name=eval -c user.email=eval@example.com commit -qm "Baseline"
git checkout -qb feature/work
applied=0
for overlay in "$@"; do
  [ "$overlay" = "-" ] && continue
  rsync -a "$overlay/" .
  applied=1
done
if [ "$applied" = 1 ]; then
  git add -A
  git -c user.name=eval -c user.email=eval@example.com commit -qm "Work so far"
fi

# Eval sandboxes usually have no network and do not follow symlinks out of the run folder,
# so copy the sample app's dependencies in (a free clone on APFS, a plain copy elsewhere).
# Install them once with: npm ci --prefix examples/sample-app
if [ -z "${MOCKSHIP_SKIP_INSTALL:-}" ]; then
  if [ -d "$here/sample-app/node_modules" ]; then
    cp -Rc "$here/sample-app/node_modules" . 2>/dev/null || cp -R "$here/sample-app/node_modules" .
  else
    echo "scaffold: examples/sample-app/node_modules is missing; run: npm ci --prefix examples/sample-app" >&2
    exit 1
  fi
fi
