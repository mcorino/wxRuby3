#!/usr/bin/env bash

if [ "$1" == "remove" ]; then
  pacman --noconfirm -R ruby rubygems ruby-bundler
else
  pacman --noconfirm -S ruby rubygems ruby-bundler
fi
