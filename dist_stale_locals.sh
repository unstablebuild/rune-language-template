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
# normalized expansion differs from the verbatim one. Detection reads the
# grammar sources in this checkout, so a language whose grammar repo is not
# checked out is reported as unknown rather than clean — publishing decisions
# must never rest on a source tree that cannot answer the question.
#
# Publishing is per platform, so a language republished for darwin is still
# stale for linux. Pass --langs to republish a known set on another host
# instead of re-deriving it.
#
# Usage:
#   ./dist_stale_locals.sh [--list] [--dry-run] [TARGET_OS] [TARGET_ARCH]
#   ./dist_stale_locals.sh --os darwin --arch amd64
#   ./dist_stale_locals.sh --langs "starlark ada" linux amd64
#   ./dist_stale_locals.sh --langs-file stale.txt linux amd64
#
# --list        Print the stale languages and exit (no build, no bluectl).
# --dry-run     Print what would be built and published, then exit.
# --langs       Republish this whitespace-separated set, skipping detection.
# --langs-file  Republish the languages named in this file, one per line.
# --fetch       Check out missing grammar sources before detecting.
#
# TARGET_OS   — darwin | linux  (default: host OS)
# TARGET_ARCH — arm64  | amd64  (default: host arch)
#
# BLUECTL_CONFIG_DIR selects the bluectl env (prod/staging) and os-arch config,
# matching dist_all.sh. Point it at deploy/bluectl/<env>/<os>-<arch>.
set -u

usage() {
	echo "usage: $0 [--list] [--dry-run] [--fetch] [TARGET_OS] [TARGET_ARCH]"
	echo "       $0 --os <darwin|linux> --arch <arm64|amd64>"
	echo "       $0 --langs \"<lang> <lang>\" | --langs-file <path>"
	echo "  Rebuilds every package whose locals.scm still has unprefixed captures."
}

LIST_ONLY=0
DRY_RUN=0
FETCH=0
LANGS_ARG=""
LANGS_FILE=""
TARGET_OS_SET=""
TARGET_ARCH_SET=""
while [[ $# -gt 0 ]]; do
	case "$1" in
		--list)       LIST_ONLY=1; shift ;;
		--dry-run)    DRY_RUN=1; shift ;;
		--fetch)      FETCH=1; shift ;;
		--langs)      LANGS_ARG="$2"; shift 2 ;;
		--langs-file) LANGS_FILE="$2"; shift 2 ;;
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

# repo_dir_for echoes the checkout directory for a language, derived from its
# clone URL so hyphenated repos (tree-sitter-c-sharp) resolve correctly.
repo_dir_for() {
	local url="${1#*=}"
	url="${url##*/}"
	echo "${url%.git}"
}

# query_dir_for mirrors the Makefile's QUERY_SOURCE resolution so detection
# sees the same query files the build will ship.
query_dir_for() {
	local lang="$1" dir="$2"
	if [[ -f "${dir}/queries/highlights.scm" ]]; then
		echo "${dir}/queries"
	elif [[ -f "${dir}/queries/${lang}/highlights.scm" ]]; then
		echo "${dir}/queries/${lang}"
	elif [[ -f "nvim-treesitter/runtime/queries/${lang}/highlights.scm" ]]; then
		echo "nvim-treesitter/runtime/queries/${lang}"
	fi
}

# assert_expander_normalizes fails closed when the checkout predates the
# capture normalization: without it every expansion compares equal to itself
# and the scan reports a clean tree no matter how many packages are stale.
assert_expander_normalizes() {
	local probe="tree-sitter-__normalize_probe__"
	rm -rf "${probe}"
	mkdir -p "${probe}/queries"
	printf '(module) @scope\n' > "${probe}/queries/locals.scm"
	local out
	out="$(tools/expand-inherits.sh locals __normalize_probe__ 2>/dev/null)"
	rm -rf "${probe}"
	if [[ "${out}" != *"@local.scope"* ]]; then
		echo "tools/expand-inherits.sh does not normalize locals captures." >&2
		echo "This checkout predates the normalization; pull before scanning." >&2
		exit 1
	fi
}

STALE=""
UNKNOWN=""
CLEAN_COUNT=0

# classify_langs sorts every mapped language into stale, clean or unknown.
# Unknown means the grammar sources are absent, so this checkout cannot tell
# what the published package shipped.
classify_langs() {
	local line lang dir qdir fixed raw
	while IFS= read -r line; do
		lang="${line%%=*}"
		dir="$(repo_dir_for "$line")"
		if [[ ! -d "${dir}" ]]; then
			UNKNOWN="${UNKNOWN} ${lang}"
			continue
		fi
		qdir="$(query_dir_for "${lang}" "${dir}")"
		fixed="$(PRIMARY_QUERY_DIR="${qdir}" tools/expand-inherits.sh locals "$lang" 2>/dev/null)" || {
			CLEAN_COUNT=$((CLEAN_COUNT + 1))
			continue
		}
		raw="$(PRIMARY_QUERY_DIR="${qdir}" EXPAND_INHERITS_NORMALIZE=0 \
			tools/expand-inherits.sh locals "$lang" 2>/dev/null)" || {
			CLEAN_COUNT=$((CLEAN_COUNT + 1))
			continue
		}
		if [[ "$fixed" != "$raw" ]]; then
			STALE="${STALE} ${lang}"
		else
			CLEAN_COUNT=$((CLEAN_COUNT + 1))
		fi
	done < <(grep -Ev '^[[:space:]]*(#|$)' "${LANG_REPOS_FILE}")
}

# fetch_unknown checks out the grammar sources detection could not find.
fetch_unknown() {
	local lang line dir
	for lang in ${UNKNOWN}; do
		line="$(grep -E "^${lang}=" "${LANG_REPOS_FILE}" | head -1)"
		dir="$(repo_dir_for "${line}")"
		echo "fetching ${dir}" >&2
		git submodule update --init --depth 1 -- "${dir}" >&2 || true
	done
	UNKNOWN=""
	STALE=""
	CLEAN_COUNT=0
	classify_langs
}

if [[ -n "${LANGS_ARG}" || -n "${LANGS_FILE}" ]]; then
	if [[ -n "${LANGS_FILE}" ]]; then
		if [[ ! -f "${LANGS_FILE}" ]]; then
			echo "missing language list: ${LANGS_FILE}" >&2
			exit 1
		fi
		STALE="$(grep -Ev '^[[:space:]]*(#|$)' "${LANGS_FILE}" | tr '\n' ' ')"
	else
		STALE="${LANGS_ARG}"
	fi
	for lang in ${STALE}; do
		if ! grep -qE "^${lang}=" "${LANG_REPOS_FILE}"; then
			echo "unknown language: ${lang}" >&2
			exit 1
		fi
	done
else
	assert_expander_normalizes
	echo "Scanning $(grep -cEv '^[[:space:]]*(#|$)' "${LANG_REPOS_FILE}") languages for unprefixed locals captures..." >&2
	classify_langs
	if [[ "${FETCH}" -eq 1 && -n "${UNKNOWN}" ]]; then
		fetch_unknown
	fi
	if [[ -n "${UNKNOWN}" ]]; then
		echo "unknown (grammar sources not checked out):${UNKNOWN}" >&2
	fi
	if [[ -z "${STALE}" ]]; then
		if [[ -n "${UNKNOWN}" ]]; then
			echo "No stale locals.scm among the languages this checkout can read," >&2
			echo "but the ones listed above could not be checked. Re-run with --fetch," >&2
			echo "or pass --langs with the set published from another host." >&2
			exit 1
		fi
		echo "No stale locals.scm found; nothing to republish."
		exit 0
	fi
	echo "clean: ${CLEAN_COUNT}"
fi

STALE="$(echo ${STALE} | tr ' ' '\n' | grep -v '^$')"
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
