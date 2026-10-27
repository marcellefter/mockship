#!/usr/bin/env bash
# Proves the ui-to-mock check scripts pass clean mocks, fail the violations they exist to
# catch (exit 1), and report broken input as an error (exit 2) instead of passing.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
scripts="$here/../skills/ui-to-mock/scripts"
work=$(mktemp -d)
trap 'chmod -R u+rwx "$work" 2>/dev/null; rm -rf "$work"' EXIT
cd "$work"
MOCKSHIP_SKIP_INSTALL=1 bash "$here/scaffold.sh" - >/dev/null

feature=src/features/invoices
mkdir -p "$feature"
printf '# Invoices mock\n\nFlag: declared in `src/routes.tsx`\n\n## Touchpoints\n\n- `src/flags.ts`\n\n## Open questions\n' > "$feature/MOCK.md"
printf 'export const InvoiceList = () => null;\n' > "$feature/index.tsx"
printf '// invoices flag\n' >> src/flags.ts

failures=0
expect() { # expect <exit-code> <description> <command...>
  local want=$1 what=$2 got=0
  shift 2
  "$@" >/dev/null 2>&1 || got=$?
  if [ "$got" = "$want" ]; then
    echo "ok   - $what"
  else
    echo "FAIL - $what (wanted exit $want, got $got)"
    failures=$((failures + 1))
  fi
}

boundary() { bash "$scripts/check-boundary.sh" "$@"; }
tokens() { bash "$scripts/check-tokens.sh" "$@"; }

expect 0 "boundary: feature folder plus a listed touchpoint" boundary "$feature"
printf '// stray edit\n' >> src/routes.tsx
expect 1 "boundary: a file mentioned in MOCK.md but not under Touchpoints" boundary "$feature"
awk -v add="- \`src/routes.tsx\`" '{ print } /^- `src\/flags.ts`/ { print add }' "$feature/MOCK.md" > "$feature/MOCK.tmp"
mv "$feature/MOCK.tmp" "$feature/MOCK.md"
expect 0 "boundary: the same file once listed under Touchpoints" boundary "$feature"
mkdir -p "src/ünïcode" && printf 'x\n' > "src/ünïcode/a.ts"
expect 1 "boundary: an unlisted file with a non-ASCII path" boundary "$feature"
awk -v add="- \`src/ünïcode/a.ts\`" '{ print } /^- `src\/flags.ts`/ { print add }' "$feature/MOCK.md" > "$feature/MOCK.tmp" && mv "$feature/MOCK.tmp" "$feature/MOCK.md"
expect 0 "boundary: a listed file with a non-ASCII path" boundary "$feature"
expect 2 "boundary: a base branch that does not exist" boundary "$feature" no-such-branch
outside=$(mktemp -d) && mkdir -p "$outside/feature" && printf '# x\n' > "$outside/feature/MOCK.md"
expect 2 "boundary: a folder outside any git repository" boundary "$outside/feature"
rm -rf "$outside"

expect 0 "tokens: clean feature folder" tokens "$feature"
printf '.badge { color: #f3e8ff; }\n' > "$feature/Badge.module.css"
expect 1 "tokens: a literal hex colour in a stylesheet" tokens "$feature"
printf '.badge { color: var(--color-accent-fg); padding: 4px; }\n' > "$feature/Badge.module.css"
expect 1 "tokens: a literal pixel size" tokens "$feature"
printf '.badge { color: var(--color-accent-fg); }\n' > "$feature/Badge.module.css"
printf "export const style = { color: '#fff' };\n" > "$feature/Pill.tsx"
expect 1 "tokens: a literal hex colour in code" tokens "$feature"
printf 'export const Pill = () => <span className="bg-purple-100" />;\n' > "$feature/Pill.tsx"
expect 1 "tokens: a raw Tailwind palette class" tokens "$feature"
printf 'export const label = "Invoice #1042 is due";\nexport const Title = () => <h1>Invoice #1042</h1>;\n' > "$feature/Pill.tsx"
expect 0 "tokens: an invoice number in copy, without any marker" tokens "$feature"
printf 'export const anchor = "#add"; // mockship-allow\n' > "$feature/Pill.tsx"
expect 0 "tokens: a non-styling value excused with mockship-allow" tokens "$feature"
printf 'export const invoices = [{ number: "#1042", total: 12 }];\n' > "$feature/mockData.ts"
expect 0 "tokens: fixture values in mockData are ignored" tokens "$feature"
if [ "$(id -u)" != "0" ]; then
  mkdir -p "$feature/locked" && printf 'x\n' > "$feature/locked/a.ts" && chmod 000 "$feature/locked"
  expect 2 "tokens: an unreadable folder is an error, not a pass" tokens "$feature"
  chmod 755 "$feature/locked"
fi
expect 2 "tokens: a folder that does not exist" tokens "$feature/missing"

if [ "$failures" -eq 0 ]; then echo "all script checks passed"; else echo "$failures check(s) failed"; exit 1; fi
