#!/usr/bin/env bash

cat /etc/pacman.conf
sed -E -i "/DownloadUser\s+=\s+alpm/d" /etc/pacman.conf
cat /etc/pacman.conf

pacman -Syyu
pacman -q -S --noconfirm --needed pamac-cli -d libxml2 libxml2-legacy

pamac install --no-confirm glibc which git make gcc autogen automake autoconf pkgconf libyaml xorg-server-xvfb xorg-fonts-75dpi
if [ "$1" == "test" ]; then
  pamac install --no-confirm gtk3 webkit2gtk-4.1 gdk-pixbuf2 librsvg adwaita-icon-theme gnome-keyring gspell libvoikko hspell nuspell libunwind gstreamer curl libsecret libnotify libpng
fi
