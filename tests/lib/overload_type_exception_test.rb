# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './wxframe_runner'

class DirectorTypeExceptionTests < WxRuby::Test::GUITests

  class InvalidOutputSizer < Wx::BoxSizer

    def calc_min
      nil #Wx::Point.new(1,1) # expects Wx::Size
    end

  end

  def test_invalid_output
    szr = InvalidOutputSizer.new(Wx::Orientation::VERTICAL)
    szr.add(Wx::Button.new(frame_win, name: 'button'), Wx::Direction::TOP)
    frame_win.sizer = szr
    frame_win.layout
    frame_win.sizer = nil
  end

end
