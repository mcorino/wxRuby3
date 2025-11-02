#!/usr/bin/env bash

pacman -Syyu
pacman -q -S --noconfirm --needed pamac-cli -d doxygen libxml2 libxml2-legacy

pamac install --no-confirm which git make gcc autogen automake autoconf pkgconf libyaml xorg-server-xvfb xorg-fonts-75dpi
if [ "$1" == "test" ]; then
  pamac install --no-confirm gtk3 webkit2gtk.* gdk-pixbuf2 adwaita-icon-theme gnome-keyring gspell libvoikko hspell nuspell libunwind gstreamer curl libsecret libnotify libpng
fi
