#!/usr/bin/env bash

if [ "$CIRRUS_TAG" == "" ]; then
  CIRRUS_TAG=$(ruby tools/scripts/cirrus/get_release_tag.rb)
  rc=$?
  if [ "$rc" != "0" ]; then
    echo "$CIRRUS_TAG"
    exit $rc
  fi
fi

gem sources --add "https://mcorino:$GITHUB_TOKEN@rubygems.pkg.github.com/mcorino/"

WXRUBY_VERSION=${CIRRUS_TAG/#v/}
if grep -q "\-[a-zA-Z]" <<< "$CIRRUS_TAG" ; then
  WXRUBY_PRERELEASE="--pre"
else
  WXRUBY_PRERELEASE=""
fi
if [ "$distro" == "macosx" ]; then
  gem install wxruby3 -v "$WXRUBY_VERSION" ${WXRUBY_PRERELEASE} --no-format-executable && wxruby test --exclude=test_intl --exclude=test_media_ctrl
else
  gem install wxruby3 -v "$WXRUBY_VERSION" ${WXRUBY_PRERELEASE} --no-format-executable && xvfb-run -a -s '-screen 0 1600x1200x24' wxruby test --exclude=test_intl --exclude=test_media_ctrl
fi
