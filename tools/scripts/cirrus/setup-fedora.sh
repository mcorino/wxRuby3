#!/usr/bin/env bash

dnf install -y git xorg-x11-server-Xvfb xorg-x11-fonts-75dpi which gcc make procps-ng gawk
if [ "$1" == "test" ]; then
  dnf install -y gtk3 webkit2gtk4.1 mesa-libGLU gspell libnotify libsecret curl
fi
