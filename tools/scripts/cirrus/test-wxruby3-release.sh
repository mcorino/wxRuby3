#!/usr/bin/env bash

if [ "$CIRRUS_BUILD_SOURCE" == "api" ]; then
  bundle install
  bundle exec rake gem
  if [ "$distro" == "macosx" ]; then
    gem install $(echo pkg/*.gem) && wxruby test --exclude=test_intl --exclude=test_media_ctrl
  else
    gem install $(echo pkg/*.gem) && xvfb-run -a -s '-screen 0 1600x1200x24' wxruby test --exclude=test_intl --exclude=test_media_ctrl
  fi
else
  WXRUBY_VERSION=${CIRRUS_TAG/#v/}
  if grep -q "\-[a-zA-Z]" <<< "$CIRRUS_TAG" ; then
    WXRUBY_PRERELEASE="--pre"
  else
    WXRUBY_PRERELEASE=""
  fi
  if [ "$distro" == "macosx" ]; then
    gem install wxruby3 -v "$WXRUBY_VERSION" ${WXRUBY_PRERELEASE} && wxruby test --exclude=test_intl --exclude=test_media_ctrl
  else
    gem install wxruby3 -v "$WXRUBY_VERSION" ${WXRUBY_PRERELEASE} && xvfb-run -a -s '-screen 0 1600x1200x24' wxruby test --exclude=test_intl --exclude=test_media_ctrl
  fi
fi
