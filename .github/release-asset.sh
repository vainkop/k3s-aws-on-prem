#!/bin/bash -ex

export GREEN='\033[0;32m'
export YELLOW='\031[0;33m'
export RED='\033[0;31m'
export NC='\033[0m'

export GITHUB_TOKEN="$1"
export GITHUB_REPOSITORY="$2"
export RELEASE_TAG="$3"
export ASSET_NAME="$4"

export RELEASE_ID=$(curl -s \
-H "authorization: Bearer $GITHUB_TOKEN" \
https://api.github.com/repos/$GITHUB_REPOSITORY/releases | \
jq -r ".[] | select(.name==\"$RELEASE_TAG\") | .id")

export ASSET_ID=$(curl -s \
-H "authorization: Bearer $GITHUB_TOKEN" \
https://api.github.com/repos/$GITHUB_REPOSITORY/releases | \
jq -r ".[] | select(.name==\"$RELEASE_TAG\") | .assets | .[] | select(.name==\"$ASSET_NAME\") | .id")

export GH_ASSET="https://uploads.github.com/repos/$GITHUB_REPOSITORY/releases/$RELEASE_ID/assets?name=$ASSET_NAME"

export ASSET_URL=$(curl -s \
-H "authorization: Bearer $GITHUB_TOKEN" \
https://api.github.com/repos/$GITHUB_REPOSITORY/releases/tags/$RELEASE_TAG | \
jq -r ".assets[] | select(.name==\"$ASSET_NAME\") | .url")

if [ -z "$ASSET_URL" ]
then
  echo "\$ASSET_URL is empty"
  curl -s -H "authorization: Bearer $GITHUB_TOKEN" \
  --data-binary @"$ASSET_NAME" \
  -H "content-type: $(file -b --mime-type $ASSET_NAME)" $GH_ASSET
else
  echo "\$ASSET_URL is NOT empty"
  curl -s -X DELETE -H "authorization: Bearer $GITHUB_TOKEN" $ASSET_URL
  curl -s -H "authorization: Bearer $GITHUB_TOKEN" \
  --data-binary @"$ASSET_NAME" \
  -H "content-type: $(file -b --mime-type $ASSET_NAME)" $GH_ASSET
fi

printf "${GREEN}$ASSET_NAME for release $RELEASE_TAG was updated!\n${NC}"