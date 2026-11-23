#!/usr/bin/env bash
#
# comments-config.sh — print the package config.yaml that gives Rune the
# comment tokens of a language.
#
# Usage:
#   tools/comments-config.sh <lang> [comments.yaml]
#
# Prints the row of <lang> from comments.yaml nested under editor.comments,
# or nothing when the row is {} (the language has no comments to toggle).
# Exits non-zero, printing nothing, unless comments.yaml has exactly one
# row for <lang>: a language cannot ship before its comments are decided.
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
	echo "usage: $0 <lang> [comments.yaml]" >&2
	exit 2
fi
lang=$1
table=${2:-$(dirname "$0")/../comments.yaml}

if ! row=$(awk -v prefix="$lang: " \
	'index($0, prefix) == 1 { row = $0; n++ } END { if (n != 1) exit 1; print row }' "$table"); then
	echo "$table: expected exactly one row for $lang" >&2
	exit 1
fi
if [[ $row == "$lang: {}" ]]; then
	exit 0
fi
printf 'editor:\n  comments:\n    %s\n' "$row"