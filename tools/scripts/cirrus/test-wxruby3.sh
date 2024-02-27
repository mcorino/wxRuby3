#!/usr/bin/env bash

if [ "$distro" == "macosx" ]; then
  bundle exec rake test
else
  xvfb-run -a -s '-screen 0 1600x1200x24' bundle exec rake test
fi
