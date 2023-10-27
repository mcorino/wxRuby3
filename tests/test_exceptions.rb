# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class DirectorExceptionTests < WxRuby::Test::GUITests

  class InvalidOutputSizer < Wx::BoxSizer

    def calc_min
      Wx::Point.new(1,1) # expects Wx::Size
    end

  end

  def test_invalid_output
    szr = InvalidOutputSizer.new(Wx::Orientation::VERTICAL)
    szr.add(Wx::Button.new(frame_win, name: 'button'), Wx::Direction::TOP)
    frame_win.sizer = szr
    assert_raise_kind_of(TypeError) { frame_win.layout }
    frame_win.sizer = nil
  end

  class ExceptionSizer < Wx::BoxSizer

    def calc_min
      raise RuntimeError, 'AnyThing'
    end

  end

  def test_exception_in_overload
    szr = ExceptionSizer.new(Wx::Orientation::VERTICAL)
    szr.add(Wx::Button.new(frame_win, name: 'button'), Wx::Direction::TOP)
    frame_win.sizer = szr
    assert_raise_kind_of(RuntimeError) { frame_win.layout }
    frame_win.sizer = nil
  end

end
