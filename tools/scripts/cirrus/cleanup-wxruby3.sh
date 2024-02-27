#!/usr/bin/env bash

if [ "$latest_only" == "" ]; then
  bundle exec rake clean
  rm -rf ext/wxWidgets
  rm -f .wxconfig
  rm -f Gemfile.lock
fi
