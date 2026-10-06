#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  find . -type f -name '*.md' -not -path './.git/*' -exec "$0" {} +
  exit $?
fi

status=0
opening_fence_pattern='^[[:space:]]{0,3}(`{3,}|~{3,})'

contains_japanese() {
  # grep -E / bash's [[ =~ ]] mishandle multibyte character-class ranges on
  # some platforms (e.g. Git for Windows' bundled grep/bash): the CJK range
  # ー-一-龠 spuriously matches unrelated characters like an em dash (—).
  # Perl's \x{...} codepoint escapes compare actual Unicode codepoints, not
  # locale-dependent byte collation, so they don't have this problem.
  perl -CSDA -e 'exit(($ARGV[0] =~ /[\x{3041}-\x{3093}\x{30A1}-\x{30F6}\x{4E00}-\x{9FA0}\x{3005}\x{30FC}]/) ? 0 : 1)' "$1"
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
