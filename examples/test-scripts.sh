#!/usr/bin/env bash
# Proves the ui-to-mock check scripts pass clean mocks and fail the violations they exist to catch.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
scripts="$here/../skills/ui-to-mock/scripts"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"
MOCKSHIP_SKIP_INSTALL=1 bash "$here/scaffold.sh" - -

feature=src/features/invoices
mkdir -p "$feature"
printf '# Invoices mock\n\n## Touchpoints\n\n- `src/flags.ts`\n' > "$feature/MOCK.md"
printf 'export const InvoiceList = () => null;\n' > "$feature/index.tsx"
printf '// invoices flag\n' >> src/flags.ts

failures=0
expect() { # expect <pass|fail> <description> <command...>
  local want=$1 what=$2; shift 2
  if "$@" >/dev/null 2>&1; then got=pass; else got=fail; fi
  if [ "$got" = "$want" ]; then echo "ok   - $what"; else echo "FAIL - $what (wanted $want, got $got)"; failures=$((failures + 1)); fi
}

expect pass "boundary: feature folder plus a listed touchpoint" bash "$scripts/check-boundary.sh" "$feature"
printf '// stray edit\n' >> src/routes.tsx
expect fail "boundary: an unlisted file outside the feature folder" bash "$scripts/check-boundary.sh" "$feature"
printf -- '- `src/routes.tsx`\n' >> "$feature/MOCK.md"
expect pass "boundary: the same file once listed in MOCK.md" bash "$scripts/check-boundary.sh" "$feature"
expect fail "boundary: a base branch that does not exist" bash "$scripts/check-boundary.sh" "$feature" no-such-branch

expect pass "tokens: clean feature folder" bash "$scripts/check-tokens.sh" "$feature"
printf '.badge { color: #f3e8ff; }\n' > "$feature/Badge.module.css"
expect fail "tokens: a literal hex colour" bash "$scripts/check-tokens.sh" "$feature"
printf '.badge { color: var(--color-accent-fg); padding: 4px; }\n' > "$feature/Badge.module.css"
expect fail "tokens: a literal pixel size" bash "$scripts/check-tokens.sh" "$feature"
printf '.badge { color: var(--color-accent-fg); }\n' > "$feature/Badge.module.css"
printf 'export const Pill = () => <span className="bg-purple-100" />;\n' > "$feature/Pill.tsx"
expect fail "tokens: a raw Tailwind palette class" bash "$scripts/check-tokens.sh" "$feature"
printf 'export const label = "Invoice #1042"; // mockship-allow\n' > "$feature/Pill.tsx"
expect pass "tokens: a non-styling line excused with mockship-allow" bash "$scripts/check-tokens.sh" "$feature"
printf 'export const invoices = [{ number: "#1042", total: 12 }];\n' > "$feature/mockData.ts"
expect pass "tokens: fixture values in mockData are ignored" bash "$scripts/check-tokens.sh" "$feature"

[ "$failures" -eq 0 ] && echo "all script checks passed" || { echo "$failures check(s) failed"; exit 1; }
