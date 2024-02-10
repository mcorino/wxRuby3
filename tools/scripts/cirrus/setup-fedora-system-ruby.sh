#!/usr/bin/env bash

if [ "$1" == "remove" ]; then
  dnf remove -y ruby ruby-devel
else
  dnf install -y ruby ruby-devel
fi
