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

  def test_children
    frame_win.get_sizer.add(Wx::HBoxSizer.new)
    frame_win.get_sizer.add_spacer(5)
    frame_win.get_sizer.add(Wx::VBoxSizer.new)

    assert_equal(3, frame_win.sizer.item_count)
    children = frame_win.sizer.get_children
    assert_equal(3, children.size)
    assert_true(children[0].sizer?)
    assert_true(children[1].spacer?)
    assert_true(children[2].sizer?)
    frame_win.sizer.each_child do |si|
      assert_equal(children.shift.ptr_addr, si.ptr_addr)
    end
  end

  def test_user_data
    frame_win.get_sizer.add(Wx::HBoxSizer.new, 0, 0, 0, 'This is user data')
    frame_win.get_sizer.add(5,5, 0,0,0, %w[This is user data])
    frame_win.get_sizer.add(Wx::VBoxSizer.new, 0, 0, 0, {1 => 'This', 2 => 'is', 3 => 'user', 4 => 'data'})

    GC.start

    assert_equal(3, frame_win.sizer.item_count)
    children = frame_win.sizer.get_children
    assert_equal(3, children.size)
    assert_kind_of(::String, children[0].user_data)
    assert_equal('This is user data', children[0].user_data)
    assert_kind_of(::Array, children[1].user_data)
    assert_equal(%w[This is user data], children[1].user_data)
    assert_kind_of(::Hash, children[2].user_data)
    assert_equal({1 => 'This', 2 => 'is', 3 => 'user', 4 => 'data'}, children[2].user_data)

    klass = Class.new do
      def initialize
        @unlinked = false
      end
      def client_data_unlinked
        @unlinked = true
      end
      attr_reader :unlinked
    end

    frame_win.get_sizer.add(Wx::HBoxSizer.new, 0, 0, 0, klass.new)

    GC.start

    assert_equal(4, frame_win.sizer.item_count)
    assert_kind_of(klass, frame_win.get_sizer.get_item(3).user_data)
    user_data = frame_win.get_sizer.get_item(3).user_data
    assert_false(user_data.unlinked)
    frame_win.get_sizer.get_item(3).set_user_data(nil)

    GC.start

    assert_true(user_data.unlinked)
    assert_nil(frame_win.get_sizer.get_item(3).user_data)
  end

end
