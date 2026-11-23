#!/bin/sh
# Stub size rule: at most 40 changed lines unless the label "large-ok" is set.
set -eu
fail=0
while read -r number head method; do
  gh api "repos/$REPO/pulls/$number" > pull.json
  lines=$(jq '.additions + .deletions' pull.json)
  labels=$(jq -r '[.labels[].name] | join(",")' pull.json)
  live_head=$(jq -r .head.sha pull.json)
  echo "pull request $number: $lines lines, labels [$labels], author $(jq -r .user.login pull.json), draft $(jq .draft pull.json), live head $live_head, judged head $head"
  if [ "$lines" -gt 40 ] && ! echo ",$labels," | grep -q ",large-ok,"; then
    echo "too large without label"
    fail=1
  fi
done < "$1"
exit $fail
