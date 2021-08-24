#!/bin/bash -ex

export GREEN='\033[0;32m'
export YELLOW='\031[0;33m'
export RED='\033[0;31m'
export NC='\033[0m'

export GITHUB_TOKEN="$1"
export GITHUB_REPOSITORY="$2"

for ISSUE_NUMBER in $(curl -s -H 'authorization: Bearer $GITHUB_TOKEN' https://api.github.com/repos/$GITHUB_REPOSITORY/issues | jq -r '.[]|select(.title | startswith("New KUBECONFIG")) | select(.state=="open") | .number'); do
  curl -X PATCH \
  -H 'authorization: Bearer $GITHUB_TOKEN' https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$ISSUE_NUMBER \
  -d '{ "state": "closed"}' && \
  printf "${GREEN}Issue https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$ISSUE_NUMBER closed!\n${NC}"
done

printf "${GREEN}All issues were closed!\n${NC}"