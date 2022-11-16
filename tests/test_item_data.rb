require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'wx'

class TestApp < Wx::App
  attr_accessor :test_class
  def on_init
    Test::Unit::UI::Console::TestRunner.run(self.test_class)
    false
  end
end

class CtrlContainerFrame < Wx::Frame
  attr_accessor :control
  def initialize(ctrl_class, *args)
    super(nil, -1, 'Test ' + ctrl_class.name)
    self.control = ctrl_class.new(self, -1, *args)
  end
end

class TestItemData < Test::Unit::TestCase
  def assert_retrievable_data(ctrl, n, test_value)
    compare = Marshal.load( Marshal.dump(test_value) )
    ctrl.set_item_data(n, test_value)
    assert_equal(compare, ctrl.get_item_data(n) )
    GC.start
    assert_equal(compare, ctrl.get_item_data(n) )
  end

  def do_control_with_items_assertions(f)
    assert_retrievable_data(f.control, 0, { 'b' => 'B' })
    assert_retrievable_data(f.control, 1, 'string item data')
    assert_retrievable_data(f.control, 2, 42.3)
  end

  def test_treectrl_itemdata
    f = CtrlContainerFrame.new(Wx::TreeCtrl)
    tree = f.control
    root = tree.add_root('foo')
    assert_nil(tree.get_item_data( tree.get_root_item))

    id = tree.append_item(root, 'a hash', -1, -1, { :a => 7 })
    assert_equal({:a => 7 }, tree.get_item_data(id) )

    id = tree.prepend_item(root, 'a float', -1, -1, 7.8)
    assert_equal(7.8, tree.get_item_data(id) )
    GC.start
    assert_equal(7.8, tree.get_item_data(id) )

    id = tree.prepend_item(root, 'an array', -1, -1)
    assert_nil( tree.get_item_data(id) )
    tree.set_item_data(id, %w|foo bar baz|)
    assert_equal(%w|foo bar baz|,
                 f.control.get_item_data(id) )
    GC.start
    assert_equal(%w|foo bar baz|,
                 f.control.get_item_data(id) )
    f.close(true)
  end

  def test_listctrl_itemdata
    f = CtrlContainerFrame.new(Wx::ListCtrl)
    lc = f.control
    assert_equal(nil, lc.get_item_data(-7))
    assert_equal(nil, lc.get_item_data(0))
    assert_equal(nil, lc.get_item_data(118))

    lc.insert_item(0, 'string')
    assert_equal(nil, lc.get_item_data(0))

    lc.set_item_data(0, 'a string')
    assert_equal('a string', lc.get_item_data(0))
    GC.start
    assert_equal('a string', lc.get_item_data(0))

    lc.insert_item(1, 'hash')
    assert_equal(nil, lc.get_item_data(1))

    lc.set_item_data(1, { :a => 457 })
    assert_equal({ :a => 457 }, lc.get_item_data(1))
    GC.start
    assert_equal({ :a => 457 }, lc.get_item_data(1))

    assert_raises(IndexError) { lc.set_item_data(17, 3.412) }
    f.close(true)
  end


  def test_choice_itemdata
    f = CtrlContainerFrame.new(Wx::Choice, Wx::DEFAULT_POSITION,
                                Wx::DEFAULT_SIZE, %w[hash string float])
    do_control_with_items_assertions(f)
    f.close(true)
  end

   def test_listbox_itemdata
     f = CtrlContainerFrame.new(Wx::ListBox, Wx::DEFAULT_POSITION,
                                 Wx::DEFAULT_SIZE, %w[hash string float])
     do_control_with_items_assertions(f)
     f.close(true)
   end
  
   def test_combobox_itemdata
     f = CtrlContainerFrame.new(Wx::ComboBox, '', Wx::DEFAULT_POSITION,
                               Wx::DEFAULT_SIZE, %w[hash string float])
     do_control_with_items_assertions(f)
     f.close(true)
   end

   def test_checklistbox_itemdata
     f = CtrlContainerFrame.new(Wx::CheckListBox, Wx::DEFAULT_POSITION,
                                Wx::DEFAULT_SIZE, %w[hash string float])
     do_control_with_items_assertions(f)
     f.close(true)
   end
end

app = TestApp.new
app.test_class = TestItemData
app.run
