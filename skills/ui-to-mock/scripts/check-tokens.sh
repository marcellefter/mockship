#!/usr/bin/env bash
# Finds literal colours, sizes and raw palette classes in a mock's feature folder.
#
# Counted: hex values (in code only in a value position, so copy such as "Invoice #1042"
# passes), sizes with a unit, colour functions with literal arguments, raw Tailwind palette
# classes and arbitrary values.
# Not counted: colour functions wrapping a token (hsl(var(--primary))), 0px and 1px
# hairlines, @media / @container / @supports lines, Markdown, the mockData module, lines
# carrying a "mockship-allow" comment, and lines matching a pattern in a .mockship-allow file
# (one extended regex per line, # for comments) in the feature folder or the repository root.
#
# Usage: check-tokens.sh [--advisory] <feature-folder>
#   --advisory  report findings but exit 0 — for projects with no token system to follow.
# Exit codes: 0 OK (or advisory), 1 literal values found, 2 usage or read error.
set -uo pipefail

die() { echo "error: $*" >&2; exit 2; }

advisory=0
if [ "${1:-}" = "--advisory" ]; then
  advisory=1
  shift
fi
dir=${1:-}
[ -n "$dir" ] || die "usage: check-tokens.sh [--advisory] <feature-folder>"
[ -d "$dir" ] || die "$dir is not a directory"

hex_value='#([0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3,4})([^0-9a-zA-Z_-]|$)'
hex_in_code="[[\"'\`(,=:][[:space:]]*$hex_value"
size='(^|[^a-zA-Z0-9_-])[0-9]*\.?[0-9]+(px|rem|em|pt)([^a-zA-Z0-9_-]|$)'
fn='(rgba?|hsla?|oklch|oklab|lab|lch)\('
palette='(bg|text|border|ring|fill|stroke|from|via|to|outline|divide|shadow|accent|caret|decoration|placeholder)-(slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-[0-9]{2,3}'
arbitrary='-\[[^]]*(#|px|rem|rgb|hsl)'
style_pattern="$hex_value|$size|$fn|$arbitrary"
code_pattern="$hex_in_code|$size|$fn|$palette|$arbitrary"

skip=(--exclude='*.md' --exclude='mockData.*' --exclude='mock_data.*' --exclude='mock-data.*' --exclude='.mockship-allow')
styles=(--include='*.css' --include='*.scss' --include='*.sass' --include='*.less' --include='*.styl')
not_styles=(--exclude='*.css' --exclude='*.scss' --exclude='*.sass' --exclude='*.less' --exclude='*.styl')

allow_patterns=()
top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)
for allow_file in "$dir/.mockship-allow" ${top:+"$top/.mockship-allow"}; do
  [ -f "$allow_file" ] || continue
  while IFS= read -r line; do
    case "$line" in '' | '#'*) continue ;; esac
    allow_patterns+=("$line")
  done < "$allow_file"
done

candidates=$(mktemp)
trap 'rm -f "$candidates"' EXIT

scan() { # scan <pattern> <grep file filters...>
  local pattern=$1
  shift
  # File filters go before the exclusions: GNU grep keeps a file that matches no filter
  # unless the first filter is an --include.
  grep -rnE "$pattern" "$dir" "$@" "${skip[@]}" >>"$candidates"
  [ $? -le 1 ] || die "could not read every file in $dir"
}
scan "$style_pattern" "${styles[@]}"
scan "$code_pattern" "${not_styles[@]}"

found=()
while IFS= read -r hit; do
  file=${hit%%:*}
  rest=${hit#*:}
  content=${rest#*:}
  case "$content" in *mockship-allow*) continue ;; esac
  grep -qE '^[[:space:]]*@(media|container|supports)' <<<"$content" && continue
  allowed=0
  for allow in ${allow_patterns[@]+"${allow_patterns[@]}"}; do
    if grep -qE -- "$allow" <<<"$content"; then allowed=1; break; fi
  done
  [ "$allowed" = 1 ] && continue
  stripped=$(sed -E -e 's/(rgba?|hsla?|oklch|oklab|lab|lch)\([[:space:]]*var\(/var(/g' \
                    -e 's/(^|[^0-9.])[01]px/\1/g' <<<"$content")
  case "$file" in
    *.css | *.scss | *.sass | *.less | *.styl) pattern=$style_pattern ;;
    *) pattern=$code_pattern ;;
  esac
  grep -qE "$pattern" <<<"$stripped" && found+=("$hit")
done < "$candidates"

if [ ${#found[@]} -gt 0 ]; then
  if [ "$advisory" = 1 ]; then
    echo "ADVISORY: literal values in $dir (the project has no token system to replace them with):"
    printf '%s\n' "${found[@]}"
    exit 0
  fi
  echo "FAIL: literal values in $dir (use theme tokens; excuse a non-styling line with a mockship-allow comment, or a project-wide idiom with a .mockship-allow pattern):"
  printf '%s\n' "${found[@]}"
  exit 1
fi
echo "OK: no literal colours, sizes or palette classes in $dir"
