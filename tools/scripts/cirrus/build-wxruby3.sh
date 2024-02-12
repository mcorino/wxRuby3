#!/usr/bin/env bash

_ruby="system"
_binpkg=0

for a in "$@"
do
case $a in
    --latest)
    _ruby="latest"
    ;;
    --binpkg)
    _binpkg=1
    ;;
    *)
    # unknown option
    ;;
esac
done

if [ "$latest_only" == "" ] || [ "$_ruby" == "latest" ]; then
  ruby -v

  bundle install
  bundle exec rake 'configure[--with-wxwin,--autoinstall]'
  bundle exec rake build

  if [ "$_binpkg" == "1" ]; then
    bundle exec rake binpkg
  fi
fi
