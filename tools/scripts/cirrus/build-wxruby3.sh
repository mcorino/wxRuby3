#!/usr/bin/env bash

ruby -v

bundle install

bundle exec rake configure[--with-wxwin,--autoinstall]

bundle exec rake build
