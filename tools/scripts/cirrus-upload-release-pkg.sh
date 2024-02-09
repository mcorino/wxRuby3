#!/usr/bin/env bash

if [[ "$GITHUB_TOKEN" == "" ]]; then
  echo "Please provide GitHub access token via GITHUB_TOKEN environment variable!"
  exit 1
fi

if [[ "$CIRRUS_RELEASE" == "" ]]; then
  CIRRUS_RELEASE=v$(ruby -r ./lib/wx/version.rb -e "puts Wx::WXRUBY_VERSION")
fi

file_content_type="application/octet-stream"
files_to_upload=(
  # relative paths of assets to upload
)

for fpath in pkg/*.pkg
do
  echo "Uploading $fpath..."
  name=$(basename "$fpath")
  url_to_upload="https://uploads.github.com/repos/mcorino/wxruby3/releases/$CIRRUS_RELEASE/assets?name=$name"
  curl -L -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: $file_content_type" \
    $url_to_upload \
    --data-binary @$fpath
done
