# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class SizerTests < WxRuby::Test::GUITests

  def setup
    super
    frame_win.set_sizer(Wx::VBoxSizer.new)
  end

  def cleanup
    super
    GC.start
  end

  def test_detach
    frame_win.get_sizer.add(Wx::HBoxSizer.new)
    frame_win.get_sizer.add_spacer(5)
    # detaches HBoxSizer transferring ownership to Ruby; should not cause segfaults at GC
    frame_win.get_sizer.detach(0)
  end

  def test_sizer_item_detach_and_re_attach
    frame_win.get_sizer.add(Wx::HBoxSizer.new)
    frame_win.get_sizer.add_spacer(5)
    # get and detach
    szr_itm = frame_win.get_sizer.get_item(0)
    assert_not_nil(szr_itm)
    assert_true(szr_itm.is_sizer)
    szr = szr_itm.get_sizer
    assert_not_nil(szr)
    szr_itm.detach_sizer
    assert_nil(szr_itm.get_sizer)
    # remove sizer item
    assert_true(frame_win.get_sizer.remove(0))
    # re-attach detached sizer (should not cause segfaults at close due to incorrect ownership transfers)
    assert_not_nil(frame_win.get_sizer.prepend(szr))
  end

end
