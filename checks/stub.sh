#!/bin/sh
# Stub job: sleeps, then fails when a switch file for its name exists.
set -eu
name="$1"
seconds="$2"
sleep "$seconds"
if ls switches/fail-"$name"* >/dev/null 2>&1; then
  echo "switch set: $name fails"
  exit 1
fi
echo "$name ok"
