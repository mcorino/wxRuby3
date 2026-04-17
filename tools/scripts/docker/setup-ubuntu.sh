#!/usr/bin/env bash

apt-get update
apt-get install -y git make gcc gpg xvfb xfonts-75dpi curl procps
if [ "$1" == "test" ]; then
  source /etc/os-release
  case $VERSION_ID in
    24.04)
      apt-get install -y 'libgtk-3-[0-9]+' 'libwebkit2gtk-4.1-[0-9]+' 'libgspell-1-[0-9]+' libnotify4 'libsecret-1-[0-9]+' curl
      ;;
    *)
      apt-get install -y 'libgtk-3-[0-9]+' 'libwebkit2gtk-4.0-[0-9]+' 'libgspell-1-[0-9]+' libnotify4 'libsecret-1-[0-9]+' curl
      ;;
  esac
fi
