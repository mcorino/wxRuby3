#!/usr/bin/env bash

if [ "$1" == "remove" ]; then
  zypper remove -y ruby ruby-devel
else
  zypper install -y ruby ruby-devel
fi
