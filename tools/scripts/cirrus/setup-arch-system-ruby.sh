#!/usr/bin/env bash

if [ "$1" == "remove" ]; then
  pacman --noconfirm -R ruby
else
  pacman --noconfirm -S ruby
fi
