#!/usr/bin/env bash

zypper install -y git xorg-x11-server-Xvfb xvfb-run xauth xorg-x11-fonts which curl gcc make tar gzip xz zlib-devel libyaml-devel libopenssl-devel libffi-devel readline-devel libwebp-devel libexpat-devel
if [ "$1" == "test" ]; then
  zypper install -y gtk3 webkit2gtk3-devel libGLU1 gspell libnotify4 libsecret curl
fi
