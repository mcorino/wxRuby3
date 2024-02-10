#!/usr/bin/env bash

if [ "$1" == "remove" ]; then
  apt-get remove -y ruby ruby-dev
else
  apt-get install -y ruby ruby-dev
fi
