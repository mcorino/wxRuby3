#!/usr/bin/env bash

if [ "$1" == "remove" ]; then
  zypper remove -y ruby ruby-devel ruby2.5-rubygem-bundler
  zypper install -y libyaml-devel libopenssl-devel
else
  zypper install -y ruby ruby-devel ruby2.5-rubygem-bundler zlib-devel
  # provide older minitest compatible with system Ruby (2.5)
  gem install minitest -v 5.15.0
fi
