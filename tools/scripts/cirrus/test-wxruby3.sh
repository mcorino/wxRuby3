#!/usr/bin/env bash

case $distro in
  manjaro,arch)
    # Add 2 extra tests that cause problems on Arch-like distros
    export WXRUBY_TEST_EXCLUDE=$WXRUBY_TEST_EXCLUDE:test_ext_controls:test_file_dialog
    ;;
  *)
    ;;
esac

if [ "$distro" == "macosx" ]; then
  bundle exec rake test
else
  xvfb-run -a -s '-screen 0 1600x1200x24' bundle exec rake test
fi
