#!/usr/bin/env bash

zypper install -y git xorg-x11-server-Xvfb xvfb-run xorg-x11-fonts curl gcc make tar gzip
if [ "$1" == "test" ]; then
  zypper install -y gtk3 webkit2gtk4 gspell libnotify4 libsecret curl
fi
