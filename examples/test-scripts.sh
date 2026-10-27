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

# Common token idioms are not literals.
printf '.a { color: hsl(var(--primary)); background: rgb(var(--surface) / 0.5); }\n' > "$feature/Badge.module.css"
expect 0 "tokens: colour functions that wrap a token" tokens "$feature"
printf '@media (max-width: 768px) {\n  .a { display: none; }\n}\n' > "$feature/Badge.module.css"
expect 0 "tokens: a breakpoint in an @media query" tokens "$feature"
printf '.a { border: 1px solid var(--color-border); margin: 0px; }\n' > "$feature/Badge.module.css"
expect 0 "tokens: 0px and 1px hairlines" tokens "$feature"
printf '.a { box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1); }\n' > "$feature/Badge.module.css"
expect 1 "tokens: a literal rgba() colour beside a hairline" tokens "$feature"
printf '.a { font-size: 0.875rem; }\n' > "$feature/Badge.module.css"
expect 1 "tokens: a literal font size" tokens "$feature"
printf '# project idiom\nfont-size: 0\\.875rem\n' > "$feature/.mockship-allow"
expect 0 "tokens: a pattern in .mockship-allow excuses the idiom" tokens "$feature"
rm "$feature/.mockship-allow"
expect 0 "tokens: --advisory reports but passes" tokens --advisory "$feature"
printf '.a { color: var(--color-text); }\n' > "$feature/Badge.module.css"

# File-based routers and several mocks at once.
mkdir -p src/routes/invoices/[id]
printf 'export { InvoiceListPage as default } from "../../features/invoices";\n' > src/routes/invoices/page.tsx
printf 'export { InvoiceDetailPage as default } from "../../../features/invoices";\n' > "src/routes/invoices/[id]/page.tsx"
expect 1 "boundary: route files not yet listed" boundary "$feature"
awk -v add="- \`src/routes/invoices/\`" '{ print } /^## Touchpoints/ { print ""; print add }' "$feature/MOCK.md" > "$feature/MOCK.tmp" && mv "$feature/MOCK.tmp" "$feature/MOCK.md"
expect 0 "boundary: a folder touchpoint covers every route file under it" boundary "$feature"
mkdir -p src/features/quotes
printf '# Quotes mock\n\n## Touchpoints\n\n- `src/pages/Layout.tsx`\n' > src/features/quotes/MOCK.md
printf 'export const Quotes = () => null;\n' > src/features/quotes/index.tsx
printf '// quotes link\n' >> src/pages/Layout.tsx
expect 0 "boundary: another mock's folder and touchpoints are not failures" boundary "$feature"
git add -A && git -c user.name=t -c user.email=t@example.com commit -qm "mocks"
git checkout -q main && git merge -q --ff-only feature/work
expect 2 "boundary: on the base branch without a start commit" boundary "$feature"
expect 0 "boundary: on the base branch with the start commit" boundary "$feature" "$(git rev-list --max-parents=0 HEAD)"
printf 'x\n' > src/stray.ts && git add -A && git -c user.name=t -c user.email=t@example.com commit -qm stray
expect 1 "boundary: a committed stray file on the base branch is caught" boundary "$feature" "$(git rev-list --max-parents=0 HEAD)"

if [ "$failures" -eq 0 ]; then echo "all script checks passed"; else echo "$failures check(s) failed"; exit 1; fi
