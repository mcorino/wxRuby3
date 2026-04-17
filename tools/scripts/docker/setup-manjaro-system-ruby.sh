#!/usr/bin/env bash

if [ "$1" == "remove" ]; then
  pacman -R --noconfirm ruby rubygems ruby-bundler
else
  pacman -q -S --noconfirm ruby rubygems ruby-bundler
fi
