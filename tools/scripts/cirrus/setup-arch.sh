#!/usr/bin/env bash

pacman -Sy --noconfirm
pacman -q -S --noconfirm --needed which git make gcc autogen automake autoconf pkg-config libyaml xorg-server-xvfb xorg-fonts-75dpi
if [ "$1" == "test" ]; then
  pacman -q -S --noconfirm --needed pkg-config gtk3 webkit2gtk-4.1 gdk-pixbuf2 librsvg adwaita-icon-theme gnome-keyring gspell libvoikko hspell nuspell libunwind gstreamer curl libsecret libnotify libpng
fi
