#!/usr/bin/env bash

apt-get update
apt full-upgrade -y
# check if the Linuxmint /etc/os-release file has been installed
if [ "$(apt policy base-files | grep Installed | grep -c -i mint)" == "0" ]; then
  # force correct installation
  V=($(apt policy base-files | grep -E mint\[0-9]))
  apt reinstall -y --allow-downgrades base-files=${V[0]}
fi
apt-get install -y git make gcc gpg xvfb xfonts-75dpi curl procps bzip2
if [ "$1" == "test" ]; then
  source /etc/os-release
  case $VERSION_ID in
    22*|23*)
      apt-get install -y 'libgtk-3-[0-9]+' 'libwebkit2gtk-4.1-[0-9]+' 'libgspell-1-[0-9]+' libnotify4 'libsecret-1-[0-9]+' curl
      ;;
    *)
      apt-get install -y 'libgtk-3-[0-9]+' 'libwebkit2gtk-4.0-[0-9]+' 'libgspell-1-[0-9]+' libnotify4 'libsecret-1-[0-9]+' curl
      ;;
  esac
fi
