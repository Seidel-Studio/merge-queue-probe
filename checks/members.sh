#!/bin/sh
# Writes "number head_sha method" for every pull request this run covers.
set -eu
out="$1"
: > "$out"
if [ "$EVENT_NAME" = "pull_request" ]; then
  echo "$PR_NUMBER $PR_HEAD event" >> "$out"
  exit 0
fi
owner="${REPO%/*}"
name="${REPO#*/}"
gh api graphql -f owner="$owner" -f name="$name" -f query='
query($owner:String!,$name:String!){repository(owner:$owner,name:$name){
  mergeQueue(branch:"main"){entries(first:100){nodes{
    position state solo enqueuedAt baseCommit{oid} headCommit{oid}
    pullRequest{number headRefOid isDraft reviewDecision additions deletions
      author{login} labels(first:20){nodes{name}}}}}}}}' > queue.json || echo '{}' > queue.json
echo "--- queue entries as GitHub returns them"
cat queue.json
echo
echo "--- commits between base and head"
git log --format='%H %P | %an | %s' "$BASE_SHA".."$HEAD_SHA"
for commit in $(git rev-list --reverse "$BASE_SHA".."$HEAD_SHA"); do
  entry=$(jq -r --arg c "$commit" '.data.repository.mergeQueue.entries.nodes[]? | select(.headCommit.oid==$c) | "\(.pullRequest.number) \(.pullRequest.headRefOid)"' queue.json)
  if [ -n "$entry" ]; then
    echo "$entry queue-entry" >> "$out"
    continue
  fi
  rest=$(gh api "repos/$REPO/commits/$commit/pulls" --jq '.[0] | select(.) | "\(.number) \(.head.sha)"' 2>/dev/null || true)
  if [ -n "$rest" ]; then
    echo "$rest commit-pulls-api" >> "$out"
    continue
  fi
  number=$(git log -1 --format=%s "$commit" | sed -n 's/.*(#\([0-9][0-9]*\))$/\1/p')
  if [ -n "$number" ]; then
    head=$(gh api "repos/$REPO/pulls/$number" --jq .head.sha)
    echo "$number $head commit-subject" >> "$out"
    continue
  fi
  echo "no pull request found for $commit"
  exit 1
done
echo "--- branch name: $REF_NAME"
