# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class TopLevelPersistenceTests < WxRuby::Test::GUITests

  PERSIST_ROOT = 'Persistent_Options'

  def run_frame_props_tests
    Wx.persistent_register_and_restore(frame_win, 'TestFrame')

    frame_win.size = [333, 666]
    frame_win.position = [111, 444]

    Wx::PersistenceManager.get.save_and_unregister(frame_win)

    cfg = Wx::ConfigBase.get
    assert_kind_of(Wx::ConfigBase, cfg)
    grp = cfg.get(PERSIST_ROOT)
    assert_kind_of(cfg.class::Group, grp)
    grp = grp.get('Window')
    assert_kind_of(cfg.class::Group, grp)
    grp = grp.get('TestFrame')
    assert_kind_of(cfg.class::Group, grp)

    assert_equal(111, Integer(grp['x']))
    assert_equal(444, Integer(grp['y']))
    assert_equal(333, Integer(grp.w))
    assert_equal(666, Integer(grp.h))

    grp.x = 444
    grp.y = 111
    grp['w'] = 666
    grp['h'] = 333

    Wx.persistent_register_and_restore(frame_win, 'TestFrame')

    assert_equal(Wx::Size.new(666, 333), frame_win.size)
    assert_equal(Wx::Point.new(444, 111), frame_win.position)

    Wx::PersistenceManager.get.unregister(frame_win)
  end

  def test_frame_props_ruby_config
    # force creation of hash based Wx::Config instance
    Wx::ConfigBase.create(true, use_hash_config: true)

    run_frame_props_tests

    Wx::ConfigBase.get.clear
  end

  def test_frame_props_default_config
    # force creation of default C++ config instance
    Wx::ConfigBase.create(true)

    run_frame_props_tests

    Wx::ConfigBase.get.clear
  end


end
