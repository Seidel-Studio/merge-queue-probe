#!/bin/sh
# Stub review receipt: a commit status "stub-review" on the pull request head.
set -eu
fail=0
while read -r number head method; do
  state=$(gh api "repos/$REPO/commits/$head/statuses" --jq '[.[] | select(.context=="stub-review")][0].state // "missing"')
  echo "pull request $number head $head (found by $method): receipt $state"
  [ "$state" = "success" ] || fail=1
done < "$1"
exit $fail
