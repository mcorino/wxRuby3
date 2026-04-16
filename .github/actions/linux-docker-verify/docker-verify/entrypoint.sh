#!/usr/bin/env bash

distro=$1
ruby=$2

./tools/scripts/cirrus/setup-$distro.sh test

# Show some information about the system.
uname -a
locale
locale -a
cat /etc/os-release

if [ "$ruby" -eq "system" ]; then
  # testing with system ruby

  ./tools/scripts/cirrus/setup-$distro-system-ruby.sh

  ./tools/scripts/cirrus/build-wxruby3.sh 2>&1 | tee -a build-wxruby3.log

  ./tools/scripts/cirrus/test-wxruby3.sh

else
  # testing with latest ruby

  ./tools/scripts/cirrus/setup-ruby-install-latest.sh

  ./tools/scripts/cirrus/build-wxruby3.sh --latest 2>&1 | tee -a build-wxruby3.log

  ./tools/scripts/cirrus/test-wxruby3.sh
fi
