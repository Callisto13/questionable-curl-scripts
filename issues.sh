#!/bin/bash

BUG_DIR="/tmp/bug_counts"
BUG_FILE=output.csv

mkdir -p "$BUG_DIR"

trap 'rm -rf $BUG_DIR' EXIT

total=0
ownerFound=0
communityFound=0

for i in {1..14}; do
   curl \
      -u "Callisto13:$GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/weaveworks/eksctl/issues?state=all&page=$i&per_page=100" \
      > "$BUG_DIR/page$i.json"

   count=$(jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.created_at | contains("2020")) | length' < "$BUG_DIR/page$i.json" | wc -l)
   total=$((total+count))

   ownerFoundCount=$(jq -r '.[] |  select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.created_at | contains("2020")) | select(.author_association == "MEMBER") | length' < "$BUG_DIR/page$i.json"  | wc -l)
   ownerFound=$((ownerFound+ownerFoundCount))

   communityFoundCount=$(jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.created_at | contains("2020")) | select(.author_association != "MEMBER") | length' < "$BUG_DIR/page$i.json" | wc -l)
   communityFound=$((communityFound+communityFoundCount))

   jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.created_at | contains("2020")) | [.number,.created_at,.title,.author_association] | @csv' < "$BUG_DIR/page$i.json" >> "$BUG_FILE"
done

echo "\"total\",\"$total\""
echo "\"ownerFound\",\"$ownerFound\""
echo "\"communityFound\",\"$communityFound\""
