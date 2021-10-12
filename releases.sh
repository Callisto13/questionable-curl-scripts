#!/bin/bash

YEAR=2021
MONTH=09
USERNAME=
RELEASES="$YEAR-$MONTH-releases.csv"

usage() {
cat << EOF
usage: $0 -y YEAR -m MONTH [-u USERNAME]

Script to generate release data for eksctl and profiles projects.

OPTIONS:
   -y YEAR     Set the year (default: 2021)
   -m MONTH    Set the month in digital (default: 10)
   -u USERNAME Set the github username. Used in conjunction with the $TOKEN env var to avoid API rate limiting.
   -h          Show this message
EOF
}

get_releases() {
  # get releases for the month. 20 is magic, but does cover the whole month in the offchance it was very producutive
  echo "Saving $1 release data to $RELEASES"
  AUTH=
  if [[ -z "$TOKEN" || -z "$USERNAME" ]]; then
    echo "TOKEN variable not set. Recommend setting a github token and username to avoid API rate limiting. See usage -h for more."
  else
    AUTH="-u $USERNAME:$TOKEN"
  fi

  echo "$1" >> "$RELEASES"

  curl -s \
    "$AUTH" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/weaveworks/$1/releases?per_page=20" | \
    jq ".[] | select(.published_at | contains(\"$YEAR-$MONTH\")) | select(.prerelease == false) | [.tag_name,.created_at] | @csv" -r \
    >> $RELEASES
}

while getopts ":hu:y:m:" OPTION
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
    ?)
      usage
      exit
      ;;
  esac
done

get_releases eksctl
get_releases profiles # will need updating after rename
get_releases pctl # will need updating after rename
