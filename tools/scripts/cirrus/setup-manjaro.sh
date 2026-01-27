#!/usr/bin/env bash

pacman -Syyu
pacman -q -S --noconfirm --needed pamac-cli -d libxml2 libxml2-legacy

pacman -q -S --noconfirm glibc which git make gcc autogen automake autoconf pkgconf libyaml xorg-server-xvfb xorg-fonts-75dpi
if [ "$1" == "test" ]; then
  pacman -q -S --noconfirm gtk3 webkit2gtk-4.1 gdk-pixbuf2 librsvg adwaita-icon-theme gnome-keyring gspell libvoikko hspell nuspell libunwind gstreamer curl libsecret libnotify libpng
fi
