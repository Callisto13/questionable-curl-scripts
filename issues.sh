#!/bin/bash

TMP_DIR="/tmp/issues"
YEAR=2021
MONTH=09
USERNAME=
SKIP_CLEANUP=

usage() {
cat << EOF
usage: $0 -y YEAR -m MONTH [-u USERNAME]

Script to generate release data for eksctl and profiles projects.

OPTIONS:
   -y YEAR     Set the year (default: 2021)
   -m MONTH    Set the month in digital (default: 10)
   -u USERNAME Set the github username. Used in conjunction with the $TOKEN env var to avoid API rate limiting.
   -s          Skip cleaning up and re-curling
   -h          Show this message
EOF
}

curl_repo() {
   local issue_dir="$TMP_DIR/$1"
   echo "Fetching issue data for $1, saving to $issue_dir. (May take some time.)"
   local auth=
   if [[ -z "$TOKEN" || -z "$USERNAME" ]]; then
      echo "TOKEN variable not set. Recommend setting a github token and username to avoid API rate limiting. See usage -h for more."
   else
      auth="-u $USERNAME:$TOKEN"
   fi

   for i in $(seq 1 "$2"); do
      curl -s \
         "$auth" \
         -H "Accept: application/vnd.github.v3+json" \
         "https://api.github.com/repos/weaveworks/$1/issues?state=closed&page=$i&per_page=100" \
         > "$issue_dir/page$i.json"
   done
}

parse_issues() {
   local issue_dir="$TMP_DIR/$1"
   local out_dir="$1"
   local help_out="$out_dir/helps.csv"
   local bug_out="$out_dir/bugs.csv"
   local feature_out="$out_dir/features.csv"
   local zip_file="$YEAR-$MONTH-$1.zip"
   rm -f "$help_out" "$feature_out" "$bug_out" || true

   echo "Parsing issue data for $1, zipping to ./$zip_file"

   files=$(find "$issue_dir" -type f | wc -l)
   for i in $(seq 1 "$files"); do
      jq -r ".[] | select(.pull_request == null) | select(.labels[].name == \"kind/bug\") | select(.closed_at | contains(\"$YEAR-$MONTH\")) | [.number,.closed_at] | @csv" < "$issue_dir/page$i.json" >> "$bug_out"
      jq -r ".[] | select(.pull_request == null) | select(.labels[].name == \"kind/help\") | select(.closed_at | contains(\"$YEAR-$MONTH\")) | [.number,.closed_at] | @csv" < "$issue_dir/page$i.json" >> "$help_out"
      jq -r ".[] | select(.pull_request == null) | select(.labels[].name == \"kind/feature\") | select(.closed_at | contains(\"$YEAR-$MONTH\")) | [.number,.closed_at] | @csv" < "$issue_dir/page$i.json" >> "$feature_out"
   done

   zip "$zip_file" "$1"/*
   echo "Done."
}

while getopts ":hsu:y:m:" OPTION
do
  case $OPTION in
    h)
      usage
      exit
      ;;
    y)
      YEAR=$OPTARG
      ;;
    m)
      MONTH=$OPTARG
      ;;
    u)
      USERNAME=$OPTARG
      ;;
    s)
      SKIP_CLEANUP=1
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

if [[ -z "$SKIP_CLEANUP" ]]; then
   rm -rf "$TMP_DIR"
   mkdir -p "$TMP_DIR"/{eksctl,pctl,profiles}

   curl_repo eksctl 100
   curl_repo pctl 50
   curl_repo profiles 50
fi

parse_issues eksctl
parse_issues pctl
parse_issues profiles
