#!/bin/bash

# Rebuild and publish every language package whose locals.scm predates the
# capture normalization in tools/expand-inherits.sh.
#
# Rune only matches the nvim-treesitter capture vocabulary (@local.scope,
# @local.reference, @local.definition.*). Grammar repos that ship the bare
# spelling (@scope, @definition.function) produced queries that parse fine and
# match nothing, disabling go-to-definition, references and outlines for those
# languages. The expander now rewrites them, so every affected package needs a
# rebuild to pick the fix up.
#
# Affected languages are detected, not hardcoded: a language is stale when the
# normalized expansion differs from the verbatim one.
#
# Usage:
#   ./dist_stale_locals.sh [--list] [--dry-run] [TARGET_OS] [TARGET_ARCH]
#   ./dist_stale_locals.sh --os darwin --arch amd64
#
# --list      Print the stale languages and exit (no build, no bluectl).
# --dry-run   Print what would be built and published, then exit.
#
# TARGET_OS   — darwin | linux  (default: host OS)
# TARGET_ARCH — arm64  | amd64  (default: host arch)
#
# BLUECTL_CONFIG_DIR selects the bluectl env (prod/staging) and os-arch config,
# matching dist_all.sh. Point it at deploy/bluectl/<env>/<os>-<arch>.
set -u

usage() {
	echo "usage: $0 [--list] [--dry-run] [TARGET_OS] [TARGET_ARCH]"
	echo "       $0 --os <darwin|linux> --arch <arm64|amd64>"
	echo "  Rebuilds every package whose locals.scm still has unprefixed captures."
}

LIST_ONLY=0
DRY_RUN=0
TARGET_OS_SET=""
TARGET_ARCH_SET=""
while [[ $# -gt 0 ]]; do
	case "$1" in
		--list)    LIST_ONLY=1; shift ;;
		--dry-run) DRY_RUN=1; shift ;;
		--os)      TARGET_OS="$2"; shift 2 ;;
		--arch)    TARGET_ARCH="$2"; shift 2 ;;
		-h|--help) usage; exit 0 ;;
		-*) echo "unknown option: $1" >&2; usage >&2; exit 1 ;;
		*)
			if [[ -z "${TARGET_OS_SET}" ]]; then
				TARGET_OS="$1"; TARGET_OS_SET=1
			elif [[ -z "${TARGET_ARCH_SET}" ]]; then
				TARGET_ARCH="$1"; TARGET_ARCH_SET=1
			else
				echo "unexpected argument: $1" >&2; usage >&2; exit 1
			fi
			shift
			;;
	esac
done

cd "$(dirname "$0")" || exit 1

LANG_REPOS_FILE="languages.txt"
if [[ ! -f "${LANG_REPOS_FILE}" ]]; then
	echo "missing language map: ${LANG_REPOS_FILE}" >&2
	exit 1
fi

# stale_langs prints every language whose locals expansion changes under
# normalization. Languages without a locals query are skipped.
stale_langs() {
	local line lang fixed raw
	while IFS= read -r line; do
		lang="${line%%=*}"
		fixed="$(tools/expand-inherits.sh locals "$lang" 2>/dev/null)" || continue
		raw="$(EXPAND_INHERITS_NORMALIZE=0 tools/expand-inherits.sh locals "$lang" 2>/dev/null)" || continue
		if [[ "$fixed" != "$raw" ]]; then
			echo "$lang"
		fi
	done < <(grep -Ev '^[[:space:]]*(#|$)' "${LANG_REPOS_FILE}")
}

echo "Scanning $(grep -cEv '^[[:space:]]*(#|$)' "${LANG_REPOS_FILE}") languages for unprefixed locals captures..." >&2
STALE="$(stale_langs)"

if [[ -z "${STALE}" ]]; then
	echo "No stale locals.scm found; nothing to republish."
	exit 0
fi

STALE_COUNT="$(echo "${STALE}" | wc -l | tr -d ' ')"
echo "${STALE_COUNT} stale language packages:"
echo "${STALE}" | tr '\n' ' '
echo ""

if [[ "${LIST_ONLY}" -eq 1 ]]; then
	exit 0
fi

# Default to the host platform (matches the Makefile defaults).
TARGET_OS="${TARGET_OS:-$(uname | tr '[:upper:]' '[:lower:]')}"
if [[ -z "${TARGET_ARCH:-}" ]]; then
	TARGET_ARCH=$(uname -m | sed -e 's/^aarch64$/arm64/' -e 's/^x86_64$/amd64/')
fi

case "${TARGET_OS}/${TARGET_ARCH}" in
	darwin/arm64|darwin/amd64|linux/arm64|linux/amd64) ;;
	*)
		echo "unsupported TARGET_OS/TARGET_ARCH '${TARGET_OS}/${TARGET_ARCH}'" >&2
		echo "supported: darwin/arm64 darwin/amd64 linux/arm64 linux/amd64" >&2
		exit 1
		;;
esac

if [[ "${DRY_RUN}" -eq 1 ]]; then
	echo "dry run: would rebuild and publish the packages above for ${TARGET_OS}/${TARGET_ARCH}"
	exit 0
fi

# The publishing destination is never ambiguous, matching dist_all.sh.
: "${BLUECTL_CONFIG_DIR:?BLUECTL_CONFIG_DIR is not set. Point it at deploy/bluectl/<prod|staging>/<os>-<arch>.}"
export BLUECTL_CONFIG_DIR
export TARGET_OS TARGET_ARCH

echo "Rebuilding ${STALE_COUNT} packages for ${TARGET_OS}/${TARGET_ARCH}"

SUCCEEDED=""
FAILED_MAKE=""
FAILED_VERIFY=""
FAILED_DIST=""
SUCCESS_COUNT=0
FAIL_COUNT=0

for lang in ${STALE}; do
	repo="$(grep -E "^${lang}=" "${LANG_REPOS_FILE}" | head -1)"
	repo="${repo#*=}"

	echo "====> PROCESSING $lang -> $repo"

	export TARGET_LANG="$lang"
	export REPO="$repo"

	if ! make clean || ! make; then
		echo "FAILED: make for $lang"
		FAILED_MAKE="$FAILED_MAKE $lang"
		FAIL_COUNT=$((FAIL_COUNT + 1))
		continue
	fi

	if ! make verify-locals; then
		echo "FAILED: verify-locals for $lang"
		FAILED_VERIFY="$FAILED_VERIFY $lang"
		FAIL_COUNT=$((FAIL_COUNT + 1))
		continue
	fi

	if ! make dist; then
		echo "FAILED: make dist for $lang"
		FAILED_DIST="$FAILED_DIST $lang"
		FAIL_COUNT=$((FAIL_COUNT + 1))
		continue
	fi

	echo "SUCCESS: $lang"
	SUCCEEDED="$SUCCEEDED $lang"
	SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
done

echo ""
echo "==========================================="
echo " REPUBLISH SUMMARY"
echo "==========================================="
echo "Total:     ${STALE_COUNT}"
echo "Succeeded: $SUCCESS_COUNT"
echo "Failed:    $FAIL_COUNT"
echo ""

if [ -n "$SUCCEEDED" ]; then
	echo "✓ Succeeded:$SUCCEEDED"
fi

if [ -n "$FAILED_MAKE" ]; then
	echo "✗ Failed (make):$FAILED_MAKE"
fi

if [ -n "$FAILED_VERIFY" ]; then
	echo "✗ Failed (verify-locals):$FAILED_VERIFY"
fi

if [ -n "$FAILED_DIST" ]; then
	echo "✗ Failed (make dist):$FAILED_DIST"
fi

echo ""
echo "==========================================="

if [ "$FAIL_COUNT" -gt 0 ]; then
	exit 1
fi
