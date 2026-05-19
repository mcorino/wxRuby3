#!/usr/bin/env bash

_test=0

for a in "$@"
do
case $a in
    --test)
    _test=1
    ;;
    *)
    # unknown option
    ;;
esac
done

echo "Testing wxRuby3 v$WXRUBY_RELEASE"

if [ "$_test" == "1" ]; then

  gem install ./$(echo wxruby3*.gem) --no-format-executable -- package=`pwd`/$(echo wxruby3*.pkg) && xvfb-run -a -s '-screen 0 1600x1200x24' wxruby test --exclude=test_intl --exclude=test_media_ctrl

else
  gem sources --add "https://mcorino:$GITHUB_TOKEN@rubygems.pkg.github.com/mcorino/"

  gem install wxruby3 -v "$WXRUBY_VERSION" ${WXRUBY_PRERELEASE} --no-format-executable && xvfb-run -a -s '-screen 0 1600x1200x24' wxruby test --exclude=test_intl --exclude=test_media_ctrl
fi
