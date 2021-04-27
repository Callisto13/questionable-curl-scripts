#!/bin/bash

# get releases for the year. 100 is magic, but does cover the whole year
# can be made smarter in future
# also make date configurable
curl \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/weaveworks/eksctl/releases?per_page=100 | \
  jq '.[] | select(.published_at | contains("2021-03")) | select(.prerelease == false) | [.tag_name,.created_at] | @csv' -r

