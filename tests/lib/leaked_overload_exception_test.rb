# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './wxframe_runner'

class DirectorOverloadExceptionTests < WxRuby::Test::GUITests

  class ExceptionSizer < Wx::BoxSizer

    def calc_min
      raise RuntimeError, 'AnyThing'
    end

  end

  def test_exception_in_overload
    szr = ExceptionSizer.new(Wx::Orientation::VERTICAL)
    szr.add(Wx::Button.new(frame_win, name: 'button'), Wx::Direction::TOP)
    frame_win.sizer = szr
    frame_win.layout
    frame_win.sizer = nil
  end

end
