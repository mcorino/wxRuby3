#!/usr/bin/env bash

if [ "$1" == "remove" ]; then
  zypper remove -y ruby ruby-devel
  # ruby3.4-rubygem-bundler
  #zypper install -y libyaml-devel libopenssl-devel
else
  zypper install -y ruby ruby-devel
  gem install bundler --user-install
  # rubygem-bundler
  #zlib-devel
  ## provide older gems compatible with system Ruby (2.5)
  #gem install minitest -v 5.15.0
  #gem install nokogiri -v 1.12.5
fi
