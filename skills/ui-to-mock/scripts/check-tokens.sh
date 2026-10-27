#!/usr/bin/env bash
# Finds literal colours, sizes and raw palette classes in a mock's feature folder.
# Skips Markdown and the mockData module; a line containing "mockship-allow" is excused.
# Usage: check-tokens.sh <feature-folder>
set -uo pipefail

dir=${1:?usage: check-tokens.sh <feature-folder>}
[ -d "$dir" ] || { echo "error: $dir is not a directory" >&2; exit 2; }

hex='#([0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3,4})([^0-9a-zA-Z_-]|$)'
size='(^|[^a-zA-Z0-9_-])[0-9]*\.?[0-9]+(px|rem|em|pt)([^a-zA-Z0-9_-]|$)'
fn='(rgba?|hsla?|oklch|oklab|lab|lch)\('
palette='(bg|text|border|ring|fill|stroke|from|via|to|outline|divide|shadow|accent|caret|decoration|placeholder)-(slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-[0-9]{2,3}'
arbitrary='-\[[^]]*(#|px|rem|rgb|hsl)'

hits=$(grep -rnE "$hex|$size|$fn|$palette|$arbitrary" "$dir" \
  --exclude='*.md' --exclude='mockData.*' --exclude='mock_data.*' --exclude='mock-data.*' \
  | grep -v 'mockship-allow' || true)

if [ -n "$hits" ]; then
  echo "FAIL: literal values in $dir (use theme tokens, or add a mockship-allow comment if the line is not styling):"
  echo "$hits"
  exit 1
fi
echo "OK: no literal colours, sizes or palette classes in $dir"
