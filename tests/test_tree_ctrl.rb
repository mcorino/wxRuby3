# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class TreeCtrlTests < WxRuby::Test::GUITests

  def setup
    super
    @tree = Wx::TreeCtrl.new(frame_win, name: 'TreeCtrl')
  end

  def cleanup
    @tree.destroy
    super
  end

  attr_reader :tree

  def tog_style(flag)
    style = tree.get_window_style ^ flag

    if Wx.has_feature?(:WXMSW)
      # treectrl styles can't be changed on the fly using the native
      # control and the tree must be recreated
      tree.destroy
      @tree = Wx::TreeCtrl.new(frame_win, style: style, name: 'TreeCtrl')
    else
      tree.set_window_style(style)
    end
  end
  private :tog_style

  ITEMS = [
     ['Cat1', [
      'Item1.1',
      'Item1.2',
      'Item1.3'
      ]
     ],
     ['Cat2', [
       ['Cat2.1', %w[Item2.1.1 Item2.1.2] ],
      'Item2.2',
      'Item2.3'
      ]
     ],
    'Item3',
    'Item4'
  ]

  def add_tree_items(parent, items)
    items.each do |itm|
      if ::Array === itm
        cat = tree.append_item(parent, itm.first.to_s)
        add_tree_items(cat, itm.last)
      else
        tree.append_item(parent, itm.to_s)
      end
    end
  end
  private :add_tree_items

  def build_tree
    root = tree.add_root('root')
    add_tree_items(root, ITEMS)
  end
  private :build_tree

  def test_tree
    build_tree

    assert_equal(4, tree.get_item_children(tree.get_root_item).size)
    cat1 = tree.get_item_children(tree.get_root_item)[0]
    assert_equal(3, tree.get_item_children(cat1).size)
    cat2 = tree.get_item_children(tree.get_root_item)[1]
    assert_equal(3, tree.get_item_children(cat2).size)
    cat21 = tree.get_item_children(cat2)[0]
    assert_equal(2, tree.get_item_children(cat21).size)
  end

  def test_hidden_root
    tog_style(Wx::TR_HIDE_ROOT)
    build_tree

    assert_equal(4, tree.get_root_items.size)
    cat1 = tree.get_root_items[0]
    assert_equal(3, tree.get_item_children(cat1).size)
    cat2 = tree.get_root_items[1]
    assert_equal(3, tree.get_item_children(cat2).size)
    cat21 = tree.get_item_children(cat2)[0]
    assert_equal(2, tree.get_item_children(cat21).size)
  end

  def test_enumerable
    build_tree

    item211 = tree.detect { |itmid| tree.item_text(itmid) == 'Item2.1.1'}
    assert_not_nil(item211)
    assert_true(item211.ok?)
  end

  def test_enumerate
    build_tree

    tree.each_item_child(tree.get_root_item) do |itmid|
      if tree.item_text(itmid) == 'Cat2'
        tree.each_item_child(itmid) do |sub_itmid|
          if tree.item_text(sub_itmid) == 'Cat2.1'
            new_itm = tree.append_item(sub_itmid, 'Another Item')
            assert_not_nil(new_itm)
            assert_true(new_itm.ok?)
          end
        end
      end
    end
    assert_equal(4, tree.get_item_children(tree.get_root_item).size)
    cat1 = tree.get_item_children(tree.get_root_item)[0]
    assert_equal(3, tree.get_item_children(cat1).size)
    cat2 = tree.get_item_children(tree.get_root_item)[1]
    assert_equal(3, tree.get_item_children(cat2).size)
    cat21 = tree.get_item_children(cat2)[0]
    assert_equal(3, tree.get_item_children(cat21).size)
  end

  def test_enumerator
    build_tree

    root_enum = tree.each_item_child(tree.get_root_item)
    assert_kind_of(::Enumerator, root_enum)
    cat2 = root_enum.detect { |itmid| tree.item_text(itmid) == 'Cat2' }
    assert_not_nil(cat2)
    assert_true(cat2.ok?)
    cat2_enum = tree.each_item_child(cat2)
    assert_equal(3, cat2_enum.to_a.size)
  end

end
