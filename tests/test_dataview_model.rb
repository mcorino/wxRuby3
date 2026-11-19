# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class TestNotifier < Wx::DVW::DataViewModelNotifier

  attr_reader :cleared, :added, :changed, :deleted, :changed_value, :resorted

  def reset_
    @cleared = @added = @changed = @deleted = @changed_value = @resorted = nil
  end
  private :reset_

  def cleared
    reset_
    @cleared = true
  end

  def item_added(parent, item)
    reset_
    !!(@added = [parent, item])
  end

  def item_changed(item)
    reset_
    !!(@changed = item)
  end

  def item_deleted(parent, item)
    reset_
    !!(@deleted = [parent, item])
  end

  def items_added(parent, items)
    reset_
    !!(@added = [parent, items])
  end

  def items_changed(items)
    reset_
    !!(@changed = items)
  end

  def items_deleted(parent, items)
    reset_
    !!(@deleted = [parent, items])
  end

  def resort
    reset_
    @resorted = true
  end

  def value_changed(item, col)
    reset_
    !!(@changed_value = [item, col])
  end

end

class TestDataViewModel < WxRuby::Test::Unit

  def setup
    super
    @model = Wx::DVW::DataViewListStore.new

    @model.append_column('bool')
    @model.append_column(Wx::Variant.new('').type)
    @model.append_column(Wx::Variant.new(100).type)
    @model.append_column(Wx::Variant.new(3.14).type)

    @model.append_item([true, 'Item 1', 101, 5.12])
    @model.append_item([false, 'Item 2', 102, 6.12])
  end

  attr_reader :model

  def teardown
    super
    @model = nil
  end

  def test_content
    assert_equal(2, model.get_item_count)
    [
      [true, 'Item 1', 101, 5.12],
      [false, 'Item 2', 102, 6.12]
    ].each_with_index do |row, l|
      row.each_with_index do |cell, c|
        assert_true(model.get_value_by_row(l, c) == cell)
      end
    end

    # base functionality
    [
      [true, 'Item 1', 101, 5.12],
      [false, 'Item 2', 102, 6.12]
    ].each_with_index do |row, l|
      item_id = model.get_item(l)
      assert_kind_of(::Integer, item_id)
      assert_equal(l, model.get_row(item_id))
      row.each_with_index do |cell, c|
        assert_true(model.has_value(item_id, c))
        assert_true(model.get_value(item_id, c) == cell)
      end
    end
  end

  def test_mutations
    model.add_notifier(the_notifier = TestNotifier.new)

    assert_nothing_raised { model.append_item([nil, 'Item 3', 103, 9.13]) }
    assert_equal(3, model.get_item_count)
    item_id = model.get_item(2)
    assert_kind_of(::Integer, item_id)

    assert_not_nil(the_notifier.added)
    assert_nil(the_notifier.added.first)
    assert_equal(item_id, the_notifier.added.last)

    assert_equal(2, model.get_row(item_id))
    assert_equal(model.get_value(item_id, 0), nil)
    assert_equal(model.get_value(item_id, 1), 'Item 3')
    assert_equal(model.get_value(item_id, 2), 103)
    assert_equal(model.get_value(item_id, 3), 9.13)

    assert_true(model.set_value(false, item_id, 0))
    assert_false(model.get_value(item_id, 0))
    assert_nil(the_notifier.changed_value)

    assert_true(model.change_value(true, item_id, 0))
    assert_true(model.get_value(item_id, 0))
    assert_not_nil(the_notifier.changed_value)
    assert_equal(item_id, the_notifier.changed_value.first)
    assert_equal(0, the_notifier.changed_value.last)

    assert_nothing_raised { model.prepend_item([nil, 'Item 0', 0, 0.00]) }
    assert_equal(4, model.get_item_count)
    item_id = model.get_item(0)
    assert_not_nil(the_notifier.added)
    assert_nil(the_notifier.added.first)
    assert_equal(item_id, the_notifier.added.last)

    assert_nothing_raised { model.resort }
    assert_true(the_notifier.resort)

    assert_nothing_raised { model.delete_item(0) }
    assert_equal(3, model.get_item_count)
    assert_not_nil(the_notifier.deleted)
    assert_nil(the_notifier.deleted.first)
    assert_equal(item_id, the_notifier.deleted.last)

    assert_nothing_raised { model.delete_all_items }
    assert_equal(0, model.get_item_count)
    assert_true(the_notifier.cleared)
  end

end

class TestDataViewCustomModel < WxRuby::Test::Unit

  class TableModel < Wx::DVW::DataViewIndexListModel

    def initialize(col_count)
      super()
      @col_count = col_count.to_i
      @table = []
    end

    def get_count
      @table.size
    end

    def get_value_by_row(row, col)
      raise IndexError unless row>=0 && row<@table.size && col>=0 && col<@col_count
      @table[row][col]
    end

    def set_value_by_row(val, row, col)
      raise IndexError unless row>=0 && row<@table.size && col>=0 && col<@col_count
      @table[row][col] = val
      value_changed(get_item(row), col)
      true
    end

    def add_rows(*row_data)
      row_data.each { |r| raise ArgumentError unless ::Array === r && r.size == @col_count }
      @table.concat(row_data)
      row_data.each { row_appended }
    end

    def delete_rows(*rows)
      rows.each { |r| raise IndexError unless r >= 0 && r < @table.size }
      rows = rows.uniq.sort!.reverse!
      rows.each { |r| @table.delete_at(r) }
      rows_deleted(rows)
    end

  end

  def setup
    super
    @model = TableModel.new(4)

    @model.add_rows([true, 'Item 1', 101, 5.12], [false, 'Item 2', 102, 6.12])
  end

  attr_reader :model

  def teardown
    super
    @model = nil
  end

  def  test_content
    assert_equal(2, model.get_count)
    [
      [true, 'Item 1', 101, 5.12],
      [false, 'Item 2', 102, 6.12]
    ].each_with_index do |row, l|
      row.each_with_index do |cell, c|
        assert_true(model.get_value_by_row(l, c) == cell)
      end
    end

    # base functionality
    [
      [true, 'Item 1', 101, 5.12],
      [false, 'Item 2', 102, 6.12]
    ].each_with_index do |row, l|
      item_id = model.get_item(l)
      assert_kind_of(::Integer, item_id)
      assert_equal(l, model.get_row(item_id))
      row.each_with_index do |cell, c|
        assert_true(model.has_value(item_id, c))
        assert_true(model.get_value(item_id, c) == cell)
      end
    end
  end

  def test_mutations
    model.add_notifier(the_notifier = TestNotifier.new)

    model.add_rows([nil, 'Item 3', 103, 9.13])
    assert_equal(3, model.get_count)
    item_id = model.get_item(2)
    assert_kind_of(::Integer, item_id)

    assert_not_nil(the_notifier.added)
    assert_nil(the_notifier.added.first)
    assert_equal(item_id, the_notifier.added.last)

    assert_equal(2, model.get_row(item_id))
    assert_equal(model.get_value(item_id, 0), nil)
    assert_equal(model.get_value(item_id, 1), 'Item 3')
    assert_equal(model.get_value(item_id, 2), 103)
    assert_equal(model.get_value(item_id, 3), 9.13)

    assert_true(model.set_value(false, item_id, 0))
    assert_false(model.get_value(item_id, 0))
    assert_not_nil(the_notifier.changed_value)
    assert_equal(item_id, the_notifier.changed_value.first)
    assert_equal(0, the_notifier.changed_value.last)

    assert_true(model.change_value(true, item_id, 0))
    assert_true(model.get_value(item_id, 0))
    assert_not_nil(the_notifier.changed_value)
    assert_equal(item_id, the_notifier.changed_value.first)
    assert_equal(0, the_notifier.changed_value.last)

    deleted_ids = [model.get_item(0), model.get_item(1)]
    model.delete_rows(0, 1)
    assert_equal(1, model.get_count)
    assert_not_nil(the_notifier.deleted)
    assert_nil(the_notifier.deleted.first)
    assert_equal(deleted_ids, the_notifier.deleted.last.sort)
  end

end

class TestDataViewTreeStore < WxRuby::Test::Unit

  def setup
    super
    @model = Wx::DVW::DataViewTreeStore.new

    folder = @model.append_container(nil, 'Folder 1')
    @model.append_item(folder, 'Item 1.1')
    @model.append_item(folder, 'Item 1.2')
    @model.append_item(folder, 'Item 1.3')

    folder = @model.append_container(nil, 'Folder 2')
    @model.append_item(folder, 'Item 2.1')
    @model.append_item(folder, 'Item 2.2')
    @model.append_item(folder, 'Item 2.3')
  end

  attr_reader :model

  def teardown
    super
    @model = nil
  end

  def test_content
    assert_equal(2, model.get_child_count(nil))
    model.get_children(nil).each do |item|
      assert_kind_of(::Integer, item)
      assert_equal(3, model.get_child_count(item))
      model.get_children(item).each do |sub_item|
        assert_kind_of(::Integer, sub_item)
        assert_match(/Item\s\d\.\d/, model.get_item_text(sub_item))
      end
    end
    folder1 = model.get_nth_child(nil, 1)
    assert_equal('Item 2.2', model.get_item_text(model.get_nth_child(folder1, 1)))
    model.set_item_data(folder1, [1, 2.0, true])
    assert_equal([1, 2.0, true], model.get_item_data(folder1))
  end

end
