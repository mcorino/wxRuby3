#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2009 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../sampler' if $0 == __FILE__
require 'wx'

# GridTableBase is an alternative way to provide data to a Wx::Grid. A
# subclass of Wx::GridTableBase is created which is reqiured to provide
# methods to report the total size of the Grid in rows and columns, and
# the contents and style of individual cells.
# 
# Then, when creating the Grid, instead of calling create_grid and
# set_value to populate it, the GridTableBase-derived class is
# associated with the Grid, and provides these functions (see below)
# 
# This approach is typically useful for dealing with very large sets of
# data, as each cell's value is only requested as it becomes visible.v
class MyGridTable < Wx::GRID::GridTableBase
  attr_reader :cols, :rows
  def initialize(rows, cols)
    super()
    @rows = rows
    @cols = cols
    @number_col = 1
  end

  # Letter labels for columns
  COLS = ('AA' .. 'ZZ').to_a

  # Firstly, a GridTableBase must indicate the size of the grid in
  # terms of rows ...
  def get_number_rows
    @rows
  end

  # ... and columns
  def get_number_cols
    @cols
  end

  def append_rows(n)
    @rows += n
    if get_view
      msg = Wx::GRID::GridTableMessage.new(self, Wx::GRID::GRIDTABLE_NOTIFY_ROWS_APPENDED, n)
      get_view.process_table_message(msg)
    end
  end

  def append_cols(n)
    @cols += n
    if get_view
      msg = Wx::GRID::GridTableMessage.new(self, Wx::GRID::GRIDTABLE_NOTIFY_COLS_APPENDED, n)
      get_view.process_table_message(msg)
    end
  end

  # Most importantly, it should be able to return any given cell's
  # contents, given its row and column reference
  def get_value(row, col)
    if col == @number_col
      (row * 5).to_s
    else
      "#{row}:#{COLS[col]}"
    end
  end 

  # This is not needed if the cell contents are simply strings. However,
  # if you wish to use custom GridCellRenderers and/or GridCellEditors,
  # this should return a type name which has the correct renderer /
  # editor defined for it in the Grid, using register_
  def get_type_name(row, col)
    if col == @number_col
      "NUMBER"
    else
      "STRING"
    end
  end

  # It should also return the attributes that should apply to any given
  # cell; this example give alternate rows red text letters
  def get_attr(row, col, attr_kind)
    attr = Wx::GRID::GridCellAttr.new
    if (row % 2).zero?
      attr.text_colour = Wx::RED
    end
    attr
  end

  # It should indicate whether any given cell is empty
  def is_empty_cell(row, col)
    false
  end

  # It may also provide labels for the columns and rows
  def get_col_label_value(col)
    COLS[col]
  end

  # If the Grid is to support write as well as read operations,
  # set_value should also be implemented. In this case, the change is
  # merely echoed back and doesn't alter the underlying value; a real
  # implementation could, for example, write back to a database
  def set_value(x, y, val)
    puts "Changing the value of cell (#{x}, #{y}) to '#{val}'"
  end
end

class GridFrame < Wx::Frame
  def initialize
    super(nil, :title => 'GridTableBase demo', :size => [600, 300])
    main_sizer = Wx::VBoxSizer.new
    # Create a grid and associate an instance of the GridTable as the
    # data provider for the grid
    @grid = Wx::GRID::Grid.new(self)

    # Define the renderers and editors used by the different data types
    # displayed in this Grid. The type of a given cell is determined by
    # calling the source's get_type_name method; see above.
    @grid.register_data_type( "STRING", 
                              Wx::GRID::GridCellStringRenderer.new,
                              Wx::GRID::GridCellTextEditor.new )
    @grid.register_data_type( "NUMBER", 
                              Wx::GRID::GridCellNumberRenderer.new,
                              Wx::GRID::GridCellNumberEditor.new(0, 500) )

    # Set the data source
    @grid.table = MyGridTable.new(10, 10)
    

    main_sizer.add(@grid, 1, Wx::EXPAND|Wx::ALL, 5)

    # Add some buttons that can change the contents
    butt_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)

    butt_1 = Wx::Button.new(self, :label => "Add row")
    # When resizing the grid to have a new number of rows or columns,
    # just tell the table
    evt_button(butt_1) do
      @grid.append_rows(1)
      @grid.force_refresh
    end
    butt_sizer.add(butt_1)

    butt_2 = Wx::Button.new(self, :label => "Add column")
    evt_button(butt_2) do
      @grid.append_cols(1)
      @grid.force_refresh
    end
    butt_sizer.add(butt_2)

    main_sizer.add(butt_sizer, 0, Wx::EXPAND|Wx::ALL, 5)
    self.sizer = main_sizer
  end
end

module GridTableSample

  include WxRuby::Sample

  def self.describe
    Description.new(
      file: __FILE__,
      summary: 'wxRuby GridTable example.',
      description: 'wxRuby example showcasing a custom GridTable for a Grid control.')
  end

  def self.activate
    frame = GridFrame.new
    frame.show
    frame
  end

  if $0 == __FILE__
    Wx::App.run { GridTableSample.activate }
  end

end
