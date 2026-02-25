# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxrb_test'
require 'wx'

class AppInitExitExceptions < Minitest::Test

  class TestApp < Wx::App
    def on_init
      raise RuntimeError, 'on_init exception'
    end
  end

  def test_on_init_exception
    assert_raises(RuntimeError) { TestApp.run }
  end

end
