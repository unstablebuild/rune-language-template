#!/bin/bash

# Build and publish every language package for a single OS/arch target.
#
# Usage:
#   ./dist_all.sh [TARGET_OS] [TARGET_ARCH]
#   ./dist_all.sh --os darwin --arch amd64
#
# TARGET_OS   — darwin | linux  (default: host OS)
# TARGET_ARCH — arm64  | amd64  (default: host arch)
#
# The values are exported so the Makefile uses them for every language.
usage() {
	echo "usage: $0 [TARGET_OS] [TARGET_ARCH]"
	echo "       $0 --os <darwin|linux> --arch <arm64|amd64>"
	echo "  TARGET_OS defaults to the host OS, TARGET_ARCH to the host arch."
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--os)   TARGET_OS="$2"; shift 2 ;;
		--arch) TARGET_ARCH="$2"; shift 2 ;;
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

# Default to the host platform (matches the Makefile defaults).
TARGET_OS="${TARGET_OS:-$(uname | tr '[:upper:]' '[:lower:]')}"
if [[ -z "${TARGET_ARCH}" ]]; then
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

# The bluectl config dir (env + os/arch) is selected by the make target. Fail
# fast for bare invocations so the publishing destination is never ambiguous.
: "${BLUECTL_CONFIG_DIR:?BLUECTL_CONFIG_DIR is not set. Use the dist-all-{prod,staging}-* make targets so the bluectl env+os+arch is selected by the target.}"
export BLUECTL_CONFIG_DIR

export TARGET_OS TARGET_ARCH
echo "Building all packages for ${TARGET_OS}/${TARGET_ARCH}"

# The language -> repository map is shared with dist_stale_locals.sh.
LANG_REPOS_FILE="$(dirname "$0")/languages.txt"
if [[ ! -f "${LANG_REPOS_FILE}" ]]; then
	echo "missing language map: ${LANG_REPOS_FILE}" >&2
	exit 1
fi
LANG_REPOS="$(grep -Ev '^[[:space:]]*(#|$)' "${LANG_REPOS_FILE}")"

SUCCEEDED=""
FAILED_NOTFOUND=""
FAILED_CLEAN=""
FAILED_MAKE=""
FAILED_BLUECTL=""
FAILED_DIST=""
TOTAL=0
SUCCESS_COUNT=0
FAIL_COUNT=0

IFS=$'\n'
for line in $LANG_REPOS; do
    lang="${line%%=*}"
    repo="${line#*=}"

    echo "====> PROCESSING $lang -> $repo"

    export TARGET_LANG=$lang
    export REPO=$repo

    if ! make clean; then
        echo "FAILED: make clean for $lang"
        FAILED_CLEAN="$FAILED_CLEAN $lang"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi

    if ! make; then
        echo "FAILED: make for $lang"
        FAILED_MAKE="$FAILED_MAKE $lang"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi

    if ! bluectl package create -d notes="Rune language package for the $lang programming language." $lang; then
        echo "FAILED: bluectl package create for $lang"
        FAILED_BLUECTL="$FAILED_BLUECTL $lang"
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
unset IFS

# Print summary
echo ""
echo "==========================================="
echo " BUILD SUMMARY"
echo "==========================================="
echo "Total:     $TOTAL"
echo "Succeeded: $SUCCESS_COUNT"
echo "Failed:    $FAIL_COUNT"
echo ""

if [ -n "$SUCCEEDED" ]; then
    echo "✓ Succeeded:$SUCCEEDED"
fi

if [ -n "$FAILED_NOTFOUND" ]; then
    echo "✗ Failed (repo not found):$FAILED_NOTFOUND"
fi

if [ -n "$FAILED_CLEAN" ]; then
    echo "✗ Failed (make clean):$FAILED_CLEAN"
fi

if [ -n "$FAILED_MAKE" ]; then
    echo "✗ Failed (make):$FAILED_MAKE"
fi

if [ -n "$FAILED_BLUECTL" ]; then
    echo "✗ Failed (bluectl):$FAILED_BLUECTL"
fi

if [ -n "$FAILED_DIST" ]; then
    echo "✗ Failed (make dist):$FAILED_DIST"
fi

echo ""
echo "==========================================="

# Exit with error if any failures
if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
