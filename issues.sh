#!/bin/bash

ISSUE_DIR="/tmp/bug_counts"
HELP_OUT=helps.csv
BUG_OUT=bugs.csv
FEATURE_OUT=features.csv

mkdir -p "$ISSUE_DIR"
rm $HELP_OUT $BUG_OUT $FEATURE_OUT

trap 'rm -rf $ISSUE_DIR' EXIT

# january=0
# february=0
# march=0

# comment this out to simply parse files again
# TODO have a flag for this
for i in {1..100}; do # have to go quite far back through years of issues
   curl -u "Callisto13:$GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/weaveworks/eksctl/issues?state=closed&page=$i&per_page=100" \
      > "$ISSUE_DIR/page$i.json"
done

# TODO for number of files or smth
for i in {1..100}; do
   # curl \
   #    -u "Callisto13:$GITHUB_TOKEN" \
   #    -H "Accept: application/vnd.github.v3+json" \
   #    "https://api.github.com/repos/weaveworks/eksctl/issues?state=closed&page=$i&per_page=100" \
   #    > "$ISSUE_DIR/page$i.json"

   # jcount=$(jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.closed_at | contains("2021-01")) | length' < "$ISSUE_DIR/page$i.json" | wc -l)
   # january=$((january+jcount))
   # fcount=$(jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.closed_at | contains("2021-02")) | length' < "$ISSUE_DIR/page$i.json" | wc -l)
   # february=$((february+fcount))
   # mcount=$(jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.closed_at | contains("2021-03")) | length' < "$ISSUE_DIR/page$i.json" | wc -l)
   # march=$((march+mcount))

   # ownerFoundCount=$(jq -r '.[] |  select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.created_at | contains("2020")) | select(.user.login == "errordeveloper" or .user.login == "martina-if" or .user.login == "Callisto13" or .user.login == "aclevername" or .user.login == "cPu1" or .user.login == "michaelbeaumont") | length' < "$ISSUE_DIR/page$i.json"  | wc -l)
   # ownerFound=$((ownerFound+ownerFoundCount))

   # communityFoundCount=$(jq -r '.[] |  select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.created_at | contains("2020")) | select(.user.login != "errordeveloper" and .user.login != "martina-if" and .user.login != "Callisto13" and .user.login != "aclevername" and .user.login != "cPu1" and .user.login != "michaelbeaumont") | length' < "$ISSUE_DIR/page$i.json"  | wc -l)
   # communityFound=$((communityFound+communityFoundCount))

   # countClosed=$(jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.created_at | contains("2020")) | select(.state == "closed") | length' < "$ISSUE_DIR/page$i.json" | wc -l)
   # closed=$((closed+countClosed))

   # TODO date var
   jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.closed_at | contains("2021-03")) | [.number,.closed_at] | @csv' < "$ISSUE_DIR/page$i.json" >> "$BUG_OUT"
   jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/help") | select(.closed_at | contains("2021-03")) | [.number,.closed_at] | @csv' < "$ISSUE_DIR/page$i.json" >> "$HELP_OUT"
   jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/feature") | select(.closed_at | contains("2021-03")) | [.number,.closed_at] | @csv' < "$ISSUE_DIR/page$i.json" >> "$FEATURE_OUT"
   # jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.created_at | contains("2020")) | [.number,.created_at,.title,.state,.closed_at] | @csv' < "$ISSUE_DIR/page$i.json" >> "$HELP_OUT"
   # jq -r '.[] | select(.pull_request == null) | select(.labels[].name == "kind/bug") | select(.created_at | contains("2020")) | [.number,.created_at,.title,.state,.closed_at,.author_association] | @csv' < "$ISSUE_DIR/page$i.json" >> "$HELP_OUT"
done

# echo "\"january\",\"$january\""
# echo "\"february\",\"$february\""
# echo "\"march\",\"$march\""
# echo "\"ofWhichClosed\",\"$closed\""
