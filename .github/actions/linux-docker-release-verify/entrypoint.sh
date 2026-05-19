#!/usr/bin/env bash

_distro=$1
_ruby=$2
_test=$3
_release=$4
_pre=$5

export WXRUBY_VERSION=$_release
if [ "$_pre" == "1" ]; then
  export WXRUBY_PRERELEASE="--pre"
else
  export WXRUBY_PRERELEASE=""
fi

./tools/scripts/docker/setup-$_distro.sh test

# Show some information about the system.
uname -a
locale
locale -a
cat /etc/os-release

if [ "$_ruby" -eq "system" ]; then
  # testing with system ruby

  ./tools/scripts/docker/setup-$_distro-system-ruby.sh

else
  # testing with latest ruby

  ./tools/scripts/docker/setup-ruby-install-latest.sh

fi

if [ "$_test" == "1" ]; then

  ./tools/scripts/docker/test-wxruby3-release.sh --test

else

  ./tools/scripts/docker/test-wxruby3-release.sh

fi
