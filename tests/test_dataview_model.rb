# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

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
  end

end
