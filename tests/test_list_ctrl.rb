
require_relative './lib/wxframe_runner'

class ButtonTests < WxRuby::Test::GUITests

  def setup
    super
    @list = Wx::ListCtrl.new(frame_win)
    @list.set_window_style(Wx::LC_REPORT | Wx::LC_EDIT_LABELS)
    @list.set_size([400, 200])
  end

  def cleanup
    @list.destroy
    super
  end

  attr_reader :list

  def test_sort
    list.insert_column(0, "Column 0")

    list.insert_item(0, "Item 0")
    list.set_item_data(0, 0)
    list.insert_item(1, "Item 1")
    list.set_item_data(1, 1)

    list.sort_items { |i1, i2, _| i2 <=> i1 } # inverted compare

    assert_equal("Item 1", list.get_item_text(0))
    assert_equal("Item 0", list.get_item_text(1))
  end

  if Wx.has_feature?(:HAS_LISTCTRL_COLUMN_ORDER)

  def test_columns_order
    3.times { |i| list.insert_column(i, "Column #{i}") }

    order = [2, 0, 1]
    list.set_columns_order(order)

    # now list.get_columns_order() will return order
    assert_equal(order, list.get_columns_order)
    # and list.get_column_index_from_order(n) will return order[n]
    assert_equal(order[1], list.get_column_index_from_order(1))
    # and list.get_column_order() will return 1, 2 and 0 for the column 0,
    # 1 and 2 respectively
    assert_equal(1, list.get_column_order(0))
  end

  end

end
