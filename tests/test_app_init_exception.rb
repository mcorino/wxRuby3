# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require 'test/unit'
require 'wx'

class AppInitExitExceptions < Test::Unit::TestCase

  class TestApp < Wx::App
    def on_init
      raise RuntimeError, 'on_init exception'
    end
  end

  def test_on_init_exception
    assert_raise_kind_of(RuntimeError) { TestApp.run }
  end

end
