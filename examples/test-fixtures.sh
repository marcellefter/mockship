#!/usr/bin/env bash
# Sets up every eval case exactly as `claude plugin eval --scaffold` would and checks that the
# result is a sound starting point: it typechecks, and any mock in it passes the skill's own
# boundary and token checks. Needs: npm ci --prefix examples/sample-app
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/.." && pwd)
scripts="$root/skills/ui-to-mock/scripts"
failures=0

for setup in "$root"/skills/*/evals/*/place-files.sh; do
  case_name="$(basename "$(dirname "$(dirname "$(dirname "$setup")")")")/$(basename "$(dirname "$setup")")"
  work=$(mktemp -d)
  if (
    cd "$work"
    bash "$setup" >/dev/null
    npx --no-install tsc -b >/dev/null
    if [ -f src/features/invoices/MOCK.md ]; then
      bash "$scripts/check-tokens.sh" src/features/invoices >/dev/null
      bash "$scripts/check-boundary.sh" src/features/invoices main >/dev/null
    fi
  ); then
    echo "ok   - $case_name"
  else
    echo "FAIL - $case_name"
    failures=$((failures + 1))
  fi
  rm -rf "$work"
done

if [ "$failures" -eq 0 ]; then echo "all fixtures sound"; else echo "$failures fixture(s) broken"; exit 1; fi
