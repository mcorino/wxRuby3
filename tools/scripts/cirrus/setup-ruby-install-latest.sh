#!/usr/bin/env bash

curl -s -L https://raw.github.com/postmodern/postmodern.github.io/main/postmodern.asc --output postmodern.asc
gpg --import postmodern.asc

RUBY_INSTALL_LATEST_URL=$(curl -s https://api.github.com/repos/postmodern/ruby-install/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep '.tar.gz$')
RUBY_INSTALL_LATEST_FILE=$(basename $RUBY_INSTALL_LATEST_URL)
RUBY_INSTALL_LATEST_DIR=$(basename -s .tar.gz $RUBY_INSTALL_LATEST_FILE)

curl -s -L $RUBY_INSTALL_LATEST_URL --output $RUBY_INSTALL_LATEST_FILE
curl -s -L $RUBY_INSTALL_LATEST_URL.asc --output $RUBY_INSTALL_LATEST_FILE.asc

gpg --verify $RUBY_INSTALL_LATEST_FILE.asc $RUBY_INSTALL_LATEST_FILE || exit 1

tar -xzf $RUBY_INSTALL_LATEST_FILE
cd $RUBY_INSTALL_LATEST_DIR
make install
cd ..

ruby-install --system ruby -- --disable-install-rdoc --enable-shared
