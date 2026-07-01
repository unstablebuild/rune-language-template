#!/bin/bash

# Flag every published language package with metadata language=true so that
# `pkg install` in Rune can filter them out of the installable extension list.
#
# The authoritative package list comes from `bluectl package list -F json`.
# Every published package is treated as a language package EXCEPT the small,
# hardcoded set of non-language packages below. Any newly published grammar is
# therefore picked up automatically.
#
# Usage:
#   ./flag-language-packages.sh [--dry-run]
#
# --dry-run   Print the packages that would be updated and exit without
#             calling `bluectl package update`.
#
# BLUECTL_CONFIG_DIR selects the bluectl env (prod/staging). It is required so
# the publishing destination is never ambiguous, matching dist_all.sh.
set -u

usage() {
	echo "usage: $0 [--dry-run]"
	echo "  Flags every published package (except the non-language set) with language=true."
}

DRY_RUN=0
while [[ $# -gt 0 ]]; do
	case "$1" in
		--dry-run) DRY_RUN=1; shift ;;
		-h|--help) usage; exit 0 ;;
		*) echo "unknown option: $1" >&2; usage >&2; exit 1 ;;
	esac
done

: "${BLUECTL_CONFIG_DIR:?BLUECTL_CONFIG_DIR is not set. Set it so the bluectl env (prod/staging) is selected explicitly.}"
export BLUECTL_CONFIG_DIR

command -v bluectl >/dev/null || { echo "bluectl not found in PATH" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq not found in PATH" >&2; exit 1; }

# Packages that are published but are NOT language grammars.
NON_LANGUAGE_PACKAGES="fuzzy-search rune-agent runectl"

is_non_language() {
	local pkg="$1"
	for excluded in $NON_LANGUAGE_PACKAGES; do
		[[ "$pkg" == "$excluded" ]] && return 0
	done
	return 1
}

echo "Fetching published packages via bluectl package list ..."
ALL_PACKAGES=$(bluectl package list -F json | jq -r '.Name') || {
	echo "FAILED: could not list packages" >&2
	exit 1
}

if [[ -z "$ALL_PACKAGES" ]]; then
	echo "No packages returned by bluectl package list" >&2
	exit 1
fi

TARGETS=""
EXCLUDED=""
for pkg in $ALL_PACKAGES; do
	if is_non_language "$pkg"; then
		EXCLUDED="$EXCLUDED $pkg"
	else
		TARGETS="$TARGETS $pkg"
	fi
done

TARGET_COUNT=$(echo $TARGETS | wc -w | tr -d ' ')

echo ""
echo "Non-language packages (excluded):$EXCLUDED"
echo "Language packages to flag ($TARGET_COUNT):$TARGETS"
echo ""

if [[ "$DRY_RUN" -eq 1 ]]; then
	echo "--dry-run: no changes made."
	exit 0
fi

SUCCESS_COUNT=0
FAIL_COUNT=0
SUCCEEDED=""
FAILED_UPDATE=""

for pkg in $TARGETS; do
	echo "====> UPDATING $pkg (language=true)"
	if ! bluectl package update -d language=true "$pkg"; then
		echo "FAILED: bluectl package update for $pkg"
		FAILED_UPDATE="$FAILED_UPDATE $pkg"
		FAIL_COUNT=$((FAIL_COUNT + 1))
		continue
	fi
	SUCCEEDED="$SUCCEEDED $pkg"
	SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
done

echo ""
echo "==========================================="
echo " UPDATE SUMMARY"
echo "==========================================="
echo "Total:     $TARGET_COUNT"
echo "Succeeded: $SUCCESS_COUNT"
echo "Failed:    $FAIL_COUNT"
echo ""

if [[ -n "$SUCCEEDED" ]]; then
	echo "✓ Succeeded:$SUCCEEDED"
fi

if [[ -n "$FAILED_UPDATE" ]]; then
	echo "✗ Failed (bluectl package update):$FAILED_UPDATE"
fi

echo ""
echo "==========================================="

if [[ "$FAIL_COUNT" -gt 0 ]]; then
	exit 1
fi

# Re-read server state: exit codes alone are not proof the metadata landed.
echo ""
echo "Verifying language=true on all target packages ..."
MISSING=$(bluectl package list -F json |
	jq -r 'select(.Metadata.language != "true") | .Name') || {
	echo "FAILED: could not list packages for verification" >&2
	exit 1
}

UNFLAGGED=""
for pkg in $MISSING; do
	is_non_language "$pkg" || UNFLAGGED="$UNFLAGGED $pkg"
done

if [[ -n "$UNFLAGGED" ]]; then
	echo "✗ VERIFICATION FAILED: packages missing language=true:$UNFLAGGED" >&2
	exit 1
fi
echo "✓ All $TARGET_COUNT language packages have language=true."

# Spot-check that notes/latest survived the metadata merge.
echo ""
echo "Sample package (rust):"
bluectl package describe rust
