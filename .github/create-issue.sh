#!/bin/bash -ex

export GREEN='\033[0;32m'
export YELLOW='\031[0;33m'
export RED='\033[0;31m'
export NC='\033[0m'

export GITHUB_TOKEN="$1"
export GITHUB_REPOSITORY="$2"
export RELEASE_TAG="$3"
export ASSET_NAME="$4"
export GITHUB_SHA="$5"

export BROWSER_DOWNLOAD_URL=$(curl -s \
-H "authorization: Bearer $GITHUB_TOKEN" \
https://api.github.com/repos/$GITHUB_REPOSITORY/releases/tags/$RELEASE_TAG | \
jq -r ".assets[] | select(.name==\"$ASSET_NAME\") | .browser_download_url")

curl -X POST \
--url https://api.github.com/repos/$GITHUB_REPOSITORY/issues \
--header "authorization: Bearer $GITHUB_TOKEN" \
--header "content-type: $(file -b --mime-type $ASSET_NAME)" \
--data "{
  \"title\": \"New KUBECONFIG for commit: $GITHUB_SHA\",
  \"body\": \"${BROWSER_DOWNLOAD_URL}\n\"
  }"

printf "${GREEN}$ASSET_NAME download link:\n\n$BROWSER_DOWNLOAD_URL\n${NC}"