#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  find . -type f -name '*.md' -not -path './.git/*' -exec "$0" {} +
  exit $?
fi

status=0
opening_fence_pattern='^[[:space:]]{0,3}(`{3,}|~{3,})'

contains_japanese() {
  python3 - "$1" <<'PY'
import sys

text = sys.argv[1]
has_japanese = any(
    "\u3040" <= ch <= "\u30ff"
    or "\u3400" <= ch <= "\u4dbf"
    or "\u4e00" <= ch <= "\u9fff"
    or ch == "々"
    for ch in text
)
raise SystemExit(0 if has_japanese else 1)
PY
}

for file in "$@"; do
  fence_character=""
  fence_length=0
  line_number=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_number=$((line_number + 1))

    if [[ -z "$fence_character" && "$line" =~ $opening_fence_pattern ]]; then
      fence_marker="${BASH_REMATCH[1]}"
      fence_character="${fence_marker:0:1}"
      fence_length=${#fence_marker}
      continue
    fi

    if [[ -n "$fence_character" ]]; then
      closing_fence_pattern="^[[:space:]]{0,3}${fence_character}{${fence_length},}[[:space:]]*$"
      if [[ "$line" =~ $closing_fence_pattern ]]; then
        fence_character=""
        fence_length=0
      fi
      continue
    fi

    # The charter policy applies only to Markdown section headings H2-H6.
    # H1 is intentionally excluded.
    if [[ "$line" =~ ^[[:space:]]{0,3}#{2,6}[[:space:]] ]] \
      && contains_japanese "$line"; then
      printf '%s:%d: section headings must be written in English: %s\n' \
        "$file" "$line_number" "$line" >&2
      status=1
    fi
  done < "$file"
done

exit "$status"
