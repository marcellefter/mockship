#!/usr/bin/env bash
# Finds literal colours, sizes and raw palette classes in a mock's feature folder.
# In stylesheets every hex value counts; in code only a hex value in a value position
# (after a quote, colon, bracket, comma or "=") counts, so copy such as "Invoice #1042" passes.
# Skips Markdown and the mockData module; a line containing "mockship-allow" is excused.
# Usage: check-tokens.sh <feature-folder>
# Exit codes: 0 OK, 1 literal values found, 2 usage or read error.
set -uo pipefail

die() { echo "error: $*" >&2; exit 2; }

dir=${1:-}
[ -n "$dir" ] || die "usage: check-tokens.sh <feature-folder>"
[ -d "$dir" ] || die "$dir is not a directory"

hex_value='#([0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3,4})([^0-9a-zA-Z_-]|$)'
hex_in_code="[[\"'\`(,=:][[:space:]]*$hex_value"
size='(^|[^a-zA-Z0-9_-])[0-9]*\.?[0-9]+(px|rem|em|pt)([^a-zA-Z0-9_-]|$)'
fn='(rgba?|hsla?|oklch|oklab|lab|lch)\('
palette='(bg|text|border|ring|fill|stroke|from|via|to|outline|divide|shadow|accent|caret|decoration|placeholder)-(slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-[0-9]{2,3}'
arbitrary='-\[[^]]*(#|px|rem|rgb|hsl)'

skip=(--exclude='*.md' --exclude='mockData.*' --exclude='mock_data.*' --exclude='mock-data.*')
styles=(--include='*.css' --include='*.scss' --include='*.sass' --include='*.less' --include='*.styl')
not_styles=(--exclude='*.css' --exclude='*.scss' --exclude='*.sass' --exclude='*.less' --exclude='*.styl')

hits=$(mktemp)
trap 'rm -f "$hits"' EXIT

scan() { # scan <pattern> <grep options...>
  local pattern=$1
  shift
  grep -rnE "$pattern" "$dir" "${skip[@]}" "$@" >>"$hits"
  [ $? -le 1 ] || die "could not read every file in $dir"
}
scan "$hex_value|$size|$fn|$arbitrary" "${styles[@]}"
scan "$hex_in_code|$size|$fn|$palette|$arbitrary" "${not_styles[@]}"

found=$(grep -v 'mockship-allow' "$hits" || true)
if [ -n "$found" ]; then
  echo "FAIL: literal values in $dir (use theme tokens, or add a mockship-allow comment if the line is not styling):"
  echo "$found"
  exit 1
fi
echo "OK: no literal colours, sizes or palette classes in $dir"
