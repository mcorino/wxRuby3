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

  class PersistentButton < Wx::PersistentWindowBase

    def get_kind
      'Button'
    end

    def save
      save_value('w', get.size.width)
      save_value('h', get.size.height)
      save_value('label', get.label)
      save_value('my_custom_value', get.my_custom_value)
    end

    def restore
      get.size = [Integer(restore_value('w')), Integer(restore_value('h'))]
      get.label = restore_value('label')
      get.my_custom_value = Float(restore_value('my_custom_value'))
      true
    end

  end

  class MyButton < Wx::Button

    def initialize(parent=nil, name)
      super(parent, label: '', name: name)
      @my_custom_value = ''
    end

    attr_accessor :my_custom_value

    def create_persistent_object
      PersistentButton.new(self)
    end

  end

  def test_custom_persistent_object
    # force creation of hash based Wx::Config instance
    Wx::ConfigBase.create(true, use_hash_config: true)

    assert_false(Wx::ConfigBase.get.has_group?(PERSIST_ROOT))

    btn = MyButton.new(frame_win, 'AButton')
    btn.label = 'Hello world'
    btn.my_custom_value = 3.14

    Wx::PersistenceManager.get.register(btn)

    assert_false(Wx::ConfigBase.get.has_group?(PERSIST_ROOT))

    # destroying window should save and unregister
    btn.destroy
    btn = nil


    assert_true(Wx::ConfigBase.get.has_group?(PERSIST_ROOT))

    cfg = Wx::ConfigBase.get[PERSIST_ROOT]['Button']['AButton']
    assert_true(cfg.has_entry?('w'))
    assert_true(cfg.has_entry?('h'))
    assert_true(cfg.has_entry?('label'))
    assert_true(cfg.has_entry?('my_custom_value'))


    btn = MyButton.new(frame_win, 'AButton')

    Wx::PersistenceManager.get.register_and_restore(btn)

    assert_equal('Hello world', btn.label)
    assert_equal(3.14, btn.my_custom_value)
  end

end
