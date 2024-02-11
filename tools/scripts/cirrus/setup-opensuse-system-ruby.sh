#!/usr/bin/env bash

if [ "$1" == "remove" ]; then
  zypper remove -y ruby ruby-devel ruby2.5-rubygem-bundler libopenssl-1_1-devel
  zypper install -y libopenssl-devel
else
  zypper install -y ruby ruby-devel ruby2.5-rubygem-bundler
fi
