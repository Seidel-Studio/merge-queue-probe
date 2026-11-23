#!/bin/sh
# Runs every toy program; any unknown function makes the run fail.
set -eu
for program in app/*.sh; do
  echo "== $program"
  sh "$program"
done
