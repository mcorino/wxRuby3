# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require 'test/unit'
require 'wx'

class TestApp < Test::Unit::TestCase

  class TestFrame < Wx::Frame
    def initialize
      super(nil, -1, '')
      evt_paint { on_paint }
    end

    def on_paint
      paint {}
      close
    end
  end

  class TestApp < Wx::App
    def on_init
      TestFrame.new.show
    end

    def on_exit
      raise RuntimeError, 'on_exit exception'
    end
  end

  def test_self_closing_frame
    assert_raise_kind_of(RuntimeError) { TestApp.run }
  end

end
