# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class StyledTextCtrlTests < WxRuby::Test::GUITests

  def setup
    super
    @text = Wx::STC::StyledTextCtrl.new(frame_win, name: 'StyledText')
  end

  def cleanup
    @text.destroy
    super
  end

  attr_reader :text

  def test_text
    assert_equal('', text.get_value)
  end

  def test_enumerate_lines
    text.write_text <<~__HEREDOC
      This is line 1.
      This is line 2.
      This is line 3.
      __HEREDOC
    assert_equal(4, text.get_number_of_lines)
    text.each_line.each_with_index do |txt, lnr|
      if lnr < 3
        assert("This is line #{lnr+1}.", txt)
      else
        assert('', txt)
      end
    end
    txt = text.each_line { |l| break l if l.index('2')}
    assert_equal('This is line 2.', txt)
    line_enum = text.each_line
    txt = line_enum.detect { |l| l.index('3') }
    assert_equal('This is line 3.', txt)
  end

end
