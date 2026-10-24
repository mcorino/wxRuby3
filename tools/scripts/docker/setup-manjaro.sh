#!/usr/bin/env bash

pacman -Syyu
pacman -q -S --noconfirm --needed pamac-cli

pacman -q -S --noconfirm base-devel glibc which git make gcc autogen automake autoconf pkgconf libyaml xorg-server-xvfb xorg-fonts-75dpi
if [ "$1" == "test" ]; then
  pacman -q -S --noconfirm gtk3 webkit2gtk-4.1 gdk-pixbuf2 librsvg adwaita-icon-theme gnome-keyring gspell libvoikko hspell nuspell libunwind gstreamer libsecret libnotify libpng
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
ln -s /opt/swig-4.0.2/bin/swig /usr/bin/swig
