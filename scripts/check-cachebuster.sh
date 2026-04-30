#!/usr/bin/env bash
# check-cachebuster.sh — TODO #7
#
# Verify the cache-busting ?v=N suffix paired with the GitHub Pages URL
# stays in step with the number of commits on main. The convention
# (CLAUDE.md "Live URLs"): N increments by 1 with every push to main so
# iOS Safari can't serve a stale deploy.
#
# Usage:
#   bash scripts/check-cachebuster.sh
#
# Exit 0 when in sync (or when no tracked file pins a ?v=N value).
# Exit 1 when a tracked file is behind the recommended N.
#
# Files exempted from the "must be current" rule:
#   - HISTORY.md (changelog legitimately contains stale N values)
#   - CLAUDE.md  (the policy doc uses ?v=3 as an illustrative example)
#   - this script itself

set -euo pipefail

if [ -t 1 ]; then
  RED='\033[31m'; GREEN='\033[32m'; YELLOW='\033[33m'; RESET='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; RESET=''
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if ! git rev-parse --verify --quiet main >/dev/null; then
  printf "%bskip%b — local 'main' branch missing.\n" "$YELLOW" "$RESET"
  exit 0
fi

recommended_n=$(git rev-list --count main)
printf "Recommended ?v=%d  (= commit count on main)\n" "$recommended_n"

matches=$(git grep -nE '\?v=[0-9]+' -- \
  ':!HISTORY.md' \
  ':!CLAUDE.md' \
  ':!scripts/check-cachebuster.sh' \
  2>/dev/null || true)

if [ -z "$matches" ]; then
  printf "(No ?v=N references in tracked files outside HISTORY.md.)\n"
  printf "%bOK%b — share the URL with ?v=%d.\n" "$GREEN" "$RESET" "$recommended_n"
  exit 0
fi

printf "\nTracked ?v=N references:\n%s\n" "$matches"

lowest_n=$(printf "%s\n" "$matches" \
  | grep -oE '\?v=[0-9]+' \
  | grep -oE '[0-9]+' \
  | sort -n \
  | head -n 1)

if [ "$lowest_n" -lt "$recommended_n" ]; then
  printf "\n%bSTALE%b — a tracked file pins ?v=%d but main has %d commits.\n" \
    "$RED" "$RESET" "$lowest_n" "$recommended_n"
  printf "Bump the pinned value or share fresh links with ?v=%d.\n" "$recommended_n"
  exit 1
fi

printf "\n%bOK%b — tracked references are at or above %d.\n" \
  "$GREEN" "$RESET" "$recommended_n"
