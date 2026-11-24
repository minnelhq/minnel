#!/bin/sh
# Runs guards.sh once with each awk installed here (awk, mawk, gawk), putting each first on PATH
# as "awk", as the guards CI workflow does for mawk and gawk. An awk that isn't installed is named
# and skipped, so a pass covers only the awks it lists. Exits 1 if any run fails.
# Run from anywhere: plugin/scripts/tests/all-awks.sh
CDPATH= cd -- "$(dirname -- "$0")" || exit 1
tmp=$(mktemp -d) || exit 1
trap 'rm -r "$tmp"' EXIT
trap 'exit 130' INT; trap 'exit 143' TERM   # dash runs the EXIT trap only on a normal exit
fail=0
for a in awk mawk gawk; do
  path=$(command -v "$a") || { echo "skip $a: not installed"; continue; }
  mkdir "$tmp/$a" && ln -s "$path" "$tmp/$a/awk" || { echo "FAIL $a: could not link it"; fail=1; continue; }
  version=$(PATH="$tmp/$a:$PATH" awk --version 2>/dev/null | head -n 1)
  [ -n "$version" ] || version=$(PATH="$tmp/$a:$PATH" awk -W version 2>/dev/null | head -n 1)
  out=$(PATH="$tmp/$a:$PATH" ./guards.sh 2>&1); rc=$?
  if [ "$rc" = 0 ]; then
    echo "ok   $a (${version:-version unknown}): $(printf '%s\n' "$out" | grep -c '^ok') cases"
  else
    printf '%s\n' "$out" | grep '^FAIL' || printf '%s\n' "$out" | tail -n 3
    echo "FAIL $a (${version:-version unknown})"; fail=1
  fi
done
exit $fail
