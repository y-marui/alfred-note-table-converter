#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  find . -type f -name '*.md' -not -path './.git/*' -exec "$0" {} +
  exit $?
fi

status=0
opening_fence_pattern='^[[:space:]]{0,3}(`{3,}|~{3,})'

contains_japanese() {
  printf '%s\n' "$1" | grep -Eq '[ぁ-んァ-ヶ一-龠々ー]'
}

for file in "$@"; do
  fence_character=""
  fence_length=0
  line_number=0
  previous_line=""
  previous_line_number=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_number=$((line_number + 1))

    if [[ -z "$fence_character" && "$line" =~ $opening_fence_pattern ]]; then
      fence_marker="${BASH_REMATCH[1]}"
      fence_character="${fence_marker:0:1}"
      fence_length=${#fence_marker}
      previous_line=""
      previous_line_number=0
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

    if [[ "$line" =~ ^[[:space:]]{0,3}#{2,6}[[:space:]] ]] \
      && contains_japanese "$line"; then
      printf '%s:%d: section headings must be written in English: %s\n' \
        "$file" "$line_number" "$line" >&2
      status=1
    fi

    if [[ "$line" =~ ^[[:space:]]{0,3}-+[[:space:]]*$ ]] \
      && [[ -n "$previous_line" ]] \
      && contains_japanese "$previous_line"; then
      printf '%s:%d: section headings must be written in English: %s\n' \
        "$file" "$previous_line_number" "$previous_line" >&2
      status=1
    fi

    if [[ -n "${line//[[:space:]]/}" ]]; then
      previous_line="$line"
      previous_line_number=$line_number
    else
      previous_line=""
      previous_line_number=0
    fi
  done < "$file"
done

exit "$status"
