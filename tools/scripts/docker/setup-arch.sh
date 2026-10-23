#!/usr/bin/env bash

pacman -Sy --noconfirm
pacman -q -S --noconfirm --needed base-devel which git make gcc autogen automake autoconf pkg-config libyaml xorg-server-xvfb xorg-fonts-75dpi
if [ "$1" == "test" ]; then
  pacman -q -S --noconfirm --needed pkg-config gtk3 webkit2gtk-4.1 gdk-pixbuf2 librsvg adwaita-icon-theme gnome-keyring gspell libvoikko hspell nuspell libunwind gstreamer curl libsecret libnotify libpng
fi

# install AUR helper to be able to install older SWIG version
mkdir -p /tmp/yay-build
useradd -m -G wheel builder && passwd -d builder
chown -R builder:builder /tmp/yay-build
echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
su - builder -c "git clone https://aur.archlinux.org/yay.git /tmp/yay-build/yay"
su - builder -c "cd /tmp/yay-build/yay && makepkg -si --noconfirm"
su - builder -c "yay --save --answerclean All --answerdiff All"
su - builder -c "yay --save --nocleanmenu --nodiffmenu"
su - builder -c "yay -Syu"
su - builder -c "yes | yay -S --mflags '--noconfirm' swig40"
