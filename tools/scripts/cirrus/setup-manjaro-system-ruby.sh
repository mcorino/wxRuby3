#!/usr/bin/env bash

if [ "$1" == "remove" ]; then
  pamac remove --no-confirm ruby rubygems ruby-bundler
else
  pamac install --no-confirm ruby rubygems ruby-bundler
fi
