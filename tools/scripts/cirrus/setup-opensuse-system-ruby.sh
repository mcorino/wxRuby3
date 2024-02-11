#!/usr/bin/env bash

if [ "$1" == "remove" ]; then
  zypper remove -y ruby ruby-devel
else
  zypper install -y ruby ruby-devel ruby2.5-rubygem-bundler libffi-devel zlib-devel libopenssl-devel readline-devel
fi
