# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class BookCtrlTests < WxRuby::Test::GUITests

  def setup
    super
    @book = Wx::Choicebook.new(frame_win, name: 'ChoiceBook')
  end

  def cleanup
    @book.destroy
    super
    GC.start
  end

  attr_reader :book

  def test_control_sizer
    btn = Wx::Button.new(book, Wx::ID_ANY, 'First')
    # issue #199 : returning the control sizer should not cause it to be owned by Ruby
    #              because that would cause double deletes
    book.get_control_sizer.add(btn, Wx::SizerFlags.new.expand.border(Wx::ALL))
  end

end
