#!/usr/bin/env bash
#
# expand-inherits.sh — concatenate nvim-treesitter `; inherits:` query
# chains into a single self-contained .scm file.
#
# Usage:
#   tools/expand-inherits.sh <kind> <lang>
#
# Where <kind> is one of: highlights | indents | folds | locals
# and <lang> is a tree-sitter / nvim-treesitter language id (e.g. tsx).
#
# The resolved, concatenated query is printed to stdout. The script
# exits non-zero (and prints nothing) if no source file can be found
# for <kind>/<lang>.
#
# Resolution order for the *primary* (top-level) language follows the
# QUERY_SOURCE shell snippet in the Makefile (lines 279-288):
#
#   1. $PRIMARY_QUERY_DIR/<kind>.scm
#       (only honored for the top-level language; passed in by the
#        Makefile so it matches the QUERY_SOURCE auto-detection)
#   2. $REPO_DIR/queries/<kind>.scm
#   3. $REPO_DIR/queries/<lang>/<kind>.scm
#   4. nvim-treesitter/runtime/queries/<lang>/<kind>.scm
#
# For inherited parents (e.g. ecma, jsx, html_tags) typically only
# (4) applies because there is no `tree-sitter-<parent>` repo. The
# exception is the multi-grammar tree-sitter-typescript repo: when
# expanding the `typescript` parent, we prefer
# `tree-sitter-typescript/queries/<kind>.scm` over the nvim-treesitter
# copy if it exists, since the upstream is more authoritative.
#
# Inherits semantics match nvim-treesitter / neovim's tree-sitter
# query loader: each `; inherits: a,b,...` line is replaced by the
# concatenation of those parents' query files (recursively expanded)
# *prepended* to the current file's body. Listed parents are emitted
# in declaration order, but the current file's rules come last so
# they take precedence.
#
# Cycles are prevented by tracking visited <kind>:<lang> pairs in the
# `EXPAND_INHERITS_VISITED` env var (colon-separated).

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "usage: $0 <kind> <lang>" >&2
    exit 2
fi

kind="$1"
lang="$2"

# Tracks which (kind,lang) pairs we've already inlined to avoid cycles.
visited="${EXPAND_INHERITS_VISITED:-}"

# resolve_file <lang> [is_primary]
#   Echoes the path to the .scm file for this kind+lang, or nothing if
#   none is found. is_primary=1 means honor $PRIMARY_QUERY_DIR.
resolve_file() {
    local L="$1"
    local is_primary="${2:-0}"

    # (1) Top-level language: trust the Makefile's QUERY_SOURCE.
    if [ "$is_primary" = "1" ] && [ -n "${PRIMARY_QUERY_DIR:-}" ]; then
        if [ -f "$PRIMARY_QUERY_DIR/$kind.scm" ]; then
            echo "$PRIMARY_QUERY_DIR/$kind.scm"
            return 0
        fi
    fi

    # Special case: tree-sitter-typescript ships authoritative queries
    # at queries/<kind>.scm (no <lang> subdir). Honor it for the
    # `typescript` parent (and `tsx`, though tsx normally hits case 1).
    if [ "$L" = "typescript" ] || [ "$L" = "tsx" ]; then
        if [ -f "tree-sitter-typescript/queries/$kind.scm" ]; then
            echo "tree-sitter-typescript/queries/$kind.scm"
            return 0
        fi
    fi

    # (2) <repo>/queries/<kind>.scm (top-level in repo)
    if [ -f "tree-sitter-$L/queries/$kind.scm" ]; then
        echo "tree-sitter-$L/queries/$kind.scm"
        return 0
    fi

    # (3) <repo>/queries/<lang>/<kind>.scm (namespaced in repo)
    if [ -f "tree-sitter-$L/queries/$L/$kind.scm" ]; then
        echo "tree-sitter-$L/queries/$L/$kind.scm"
        return 0
    fi

    # (4) nvim-treesitter fallback.
    if [ -f "nvim-treesitter/runtime/queries/$L/$kind.scm" ]; then
        echo "nvim-treesitter/runtime/queries/$L/$kind.scm"
        return 0
    fi

    return 1
}

# extract_inherits <file>
#   Echoes the comma-separated inherits list from <file>'s first line,
#   or nothing if the first line isn't a `; inherits:` directive.
extract_inherits() {
    local f="$1"
    [ -f "$f" ] || return 0
    local first_line
    first_line="$(head -n 1 "$f" || true)"
    if [[ "$first_line" =~ ^[[:space:]]*\;[[:space:]]*inherits[[:space:]]*:[[:space:]]*(.+)$ ]]; then
        local list="${BASH_REMATCH[1]}"
        list="${list%$'\r'}"
        # Trim trailing whitespace.
        list="$(echo "$list" | sed -e 's/[[:space:]]*$//')"
        echo "$list"
    fi
}

# expand_lang <lang> <is_primary>
#   Recursively emits the fully-expanded contents of <kind>/<lang>.
#   Returns non-zero if no source file exists.
expand_lang() {
    local L="$1"
    local is_primary="${2:-0}"
    local key="$kind:$L"

    # Cycle guard.
    case ":$visited:" in
        *":$key:"*)
            return 0
            ;;
    esac
    visited="$visited:$key"

    local file
    if ! file="$(resolve_file "$L" "$is_primary")"; then
        return 1
    fi

    # Determine inherits chain. The resolved body file may not carry
    # an inherits header (typical for upstream tree-sitter-* repos
    # that only ship a partial delta). Cross-check nvim-treesitter,
    # which is the canonical home of the `; inherits:` convention.
    local inherits_list
    inherits_list="$(extract_inherits "$file")"
    local body_has_header=0
    if [ -n "$inherits_list" ]; then
        body_has_header=1
    else
        local nvt_file="nvim-treesitter/runtime/queries/$L/$kind.scm"
        if [ "$file" != "$nvt_file" ] && [ -f "$nvt_file" ]; then
            inherits_list="$(extract_inherits "$nvt_file")"
        fi
    fi

    # Edge case: in multi-grammar repos (notably tree-sitter-typescript)
    # the primary file resolved for the child language is actually the
    # parent language's body — e.g. for `tsx`, QUERY_SOURCE points at
    # `tree-sitter-typescript/queries/highlights.scm`, which is really
    # typescript content. If any inherits parent would resolve to the
    # same file, drop it as the child's body so the parent's expansion
    # owns it (preserving nvim-treesitter's parents-first ordering).
    local skip_body=0
    if [ -n "$inherits_list" ] && [ "$body_has_header" = "0" ]; then
        local IFS=','
        # shellcheck disable=SC2206
        local _parents=( $inherits_list )
        unset IFS
        local _p _stripped _pfile
        for _p in "${_parents[@]}"; do
            _stripped="$(echo "$_p" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
            [ -z "$_stripped" ] && continue
            if _pfile="$(resolve_file "$_stripped" 0)"; then
                if [ "$_pfile" = "$file" ]; then
                    skip_body=1
                    break
                fi
            fi
        done
    fi

    # Emit parents first (in declaration order), then current body.
    if [ -n "$inherits_list" ]; then
        local IFS=','
        # shellcheck disable=SC2206
        local parents=( $inherits_list )
        unset IFS
        local p stripped
        for p in "${parents[@]}"; do
            stripped="$(echo "$p" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
            [ -z "$stripped" ] && continue
            echo "; --- begin inherited: $stripped ($kind) ---"
            if ! expand_lang "$stripped" 0; then
                echo "; (no source found for inherited '$stripped')"
            fi
            echo "; --- end inherited: $stripped ($kind) ---"
        done
        if [ "$skip_body" = "0" ]; then
            echo "; --- begin $L ($kind) (from $file) ---"
            if [ "$body_has_header" = "1" ]; then
                # Skip the inherits line; emit the rest verbatim.
                tail -n +2 "$file"
            else
                cat "$file"
            fi
            echo "; --- end $L ($kind) ---"
        else
            echo "; --- $L ($kind): body folded into parent ($file) ---"
        fi
    else
        echo "; --- begin $L ($kind) (from $file) ---"
        cat "$file"
        echo "; --- end $L ($kind) ---"
    fi
}

# Top-level: emit a banner so the produced file is debuggable, then
# expand from the requested language as the primary.

# First, sanity-check that we can resolve the primary file at all. If
# not, exit non-zero with no output so the Makefile's `-` prefix can
# swallow the failure (matching the previous `cp` semantics).
if ! resolve_file "$lang" 1 >/dev/null; then
    exit 1
fi

{
    echo "; Generated by tools/expand-inherits.sh"
    echo "; kind=$kind lang=$lang"
    echo "; Inherits chains have been inlined; do not re-expand."
    echo
    expand_lang "$lang" 1
}