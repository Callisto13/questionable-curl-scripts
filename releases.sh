#!/bin/bash

# get releases for the year. 100 is magic, but does cover the whole of 2020
# can be made smarter in future
curl \
 -H "Accept: application/vnd.github.v3+json" \
 https://api.github.com/repos/weaveworks/eksctl/releases?per_page=100 | \
 jq '.[] | select(.published_at | contains("2020")) | select(.prerelease == false) | [.tag_name,.created_at] | @csv' -r

