#!/usr/bin/env bash

cat /etc/pacman.conf
sed -E -i "/#VerbosePkgLists/a\DisableSandbox" /etc/pacman.conf
cat /etc/pacman.conf
rm -f /etc/pacman.conf.pacnew
cat /etc/pacman.conf.pacnew

pacman -Syyu
pacman -q -S --noconfirm --needed pamac-cli -d libxml2 libxml2-legacy

pamac install --no-confirm glibc which git make gcc autogen automake autoconf pkgconf libyaml xorg-server-xvfb xorg-fonts-75dpi
if [ "$1" == "test" ]; then
  pamac install --no-confirm gtk3 webkit2gtk-4.1 gdk-pixbuf2 librsvg adwaita-icon-theme gnome-keyring gspell libvoikko hspell nuspell libunwind gstreamer curl libsecret libnotify libpng
fi
