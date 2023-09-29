# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require 'test/unit'
require 'wx'

class BasicTests < Test::Unit::TestCase

  def test_versions
    assert_equal(Wx::WXRUBY_VERSION, "#{Wx::WXRUBY_MAJOR}.#{Wx::WXRUBY_MINOR}.#{Wx::WXRUBY_RELEASE}-#{Wx::WXRUBY_RELEASE_TYPE}")
    assert_equal(Wx::WXWIDGETS_VERSION, "#{Wx::WXWIDGETS_MAJOR_VERSION}.#{Wx::WXWIDGETS_MINOR_VERSION}.#{Wx::WXWIDGETS_RELEASE_NUMBER}")
  end

  def test_platform
    assert(/WX[A-Z]+/ =~ Wx::PLATFORM)
  end

end
