#!/bin/sh
# Stub job: sleeps, then fails when a switch file for its name exists.
# A switch named fail-<job>-queue* only counts in a merge group run.
set -eu
name="$1"
seconds="$2"
sleep "$seconds"
for switch in switches/fail-"$name"*; do
  [ -e "$switch" ] || continue
  case "$switch" in
    switches/fail-"$name"-queue*) [ "${EVENT_NAME:-}" = "merge_group" ] || continue ;;
  esac
  echo "switch set: $name fails ($switch)"
  exit 1
done
echo "$name ok"
