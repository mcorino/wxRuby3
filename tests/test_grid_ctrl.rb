# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class GridCtrlTests < WxRuby::Test::GUITests


  class MyTextCellEditor < Wx::GRID::GridCellTextEditor
    def apply_edit(row, col, grid)
      grid.set_cell_value(row, col, "'#{get_value}'" )
    end
  end

  def setup
    super
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    make_grid(frame_win)
    sizer.add(@grid, 1, Wx::ALL|Wx::GROW, 4)
    frame_win.set_sizer(sizer)

  end

  def teardown
    frame_win.sizer.remove(0)
    @grid.destroy
    super
  end

  attr_reader :grid

  # Create a wxGrid object
  def make_grid(panel)
    @grid = Wx::GRID::Grid.new(panel, -1)

    # Then we call CreateGrid to set the dimensions of the grid
    # (11 rows and 12 columns in this example)
    @grid.create_grid( 20, 12 )
    @grid.set_default_cell_background_colour(Wx::WHITE)
    @grid.set_default_cell_text_colour(Wx::BLACK)
    # We can set the sizes of individual rows and columns
    # in pixels, and the label value string
    @grid.set_row_size( 0, 60 )
    @grid.set_row_label_value( 0, "Row1" )
    @grid.set_row_label_alignment(Wx::ALIGN_CENTRE, Wx::ALIGN_CENTRE)

    @grid.set_col_size( 0, 120 )
    @grid.set_col_label_value( 0, "Col1" )
    @grid.set_col_label_alignment(Wx::ALIGN_CENTRE, Wx::ALIGN_CENTRE)

    # And set grid cell contents as strings
    @grid.set_cell_value( 0, 0, "wxGrid is good" )

    # We can specify that some cells are read-only
    @grid.set_cell_value( 0, 2, "Read-only" )
    @grid.set_read_only( 0, 2 )

    cell_attr = Wx::GRID::GridCellAttr.new
    cell_attr.editor = MyTextCellEditor.new
    @grid.set_row_attr(1, cell_attr)
    cell_attr2 = Wx::GRID::GridCellAttr.new
    cell_attr2.editor = cell_attr.editor(@grid, 1, 1)
    @grid.set_row_attr(2, cell_attr2)

    # Colours can be specified for grid cell contents
    @grid.set_cell_value(1, 1, "white on red")
    @grid.set_cell_text_colour(1, 1, Wx::WHITE)
    @grid.set_cell_background_colour(1, 1, Wx::RED)

    # We can specify the some cells will store numeric
    # values rather than strings. Here we set grid column 6
    # to hold floating point values displayed with width
    # of 2 and precision of 2. The column is highlighted in light grey
    @grid.set_col_format_float(5, 2, 2)
    cell_attr = Wx::GRID::GridCellAttr.new
    cell_attr.set_background_colour( Wx::LIGHT_GREY )

    @grid.set_col_attr(5, cell_attr)
    @grid.set_cell_value(0, 5, "3.1415")
    @grid.set_cell_value(0, 6,
                         "The whole column to the left uses float format")

    # Custom Editors Can be used
    editor = Wx::GRID::GridCellNumberEditor.new(5, 20)
    @grid.set_cell_value(3, 1, 'Number editor below')
    @grid.set_cell_editor(4, 1, editor)

    editor = Wx::GRID::GridCellFloatEditor.new(4, 2)
    @grid.set_cell_value(3, 2, 'Float editor below')
    @grid.set_cell_editor(4, 2, editor)

    editor = Wx::GRID::GridCellChoiceEditor.new(['foo', 'bar', 'baz'])
    @grid.set_cell_value(3, 3, 'Choice editor below')
    @grid.set_cell_editor(4, 3, editor)

    @grid.auto_size_row(3, true)

    # Display of cells can be customised
    @grid.set_cell_editor(6, 0, Wx::GRID::GridCellBoolEditor.new)
    @grid.set_cell_renderer(6, 0, Wx::GRID::GridCellBoolRenderer.new)
    @grid.set_cell_value(6, 1, 'Cell to the left displayed as boolean')
  end

  def test_grid
    grid.set_grid_cursor([0, 2])
    assert_true(grid.is_current_cell_read_only)

    grid.set_grid_cursor([1, 1])
    grid.enable_cell_edit_control
    grid.get_cell_editor(*[1,1]).get_control.set_value('hello world')
    grid.save_edit_control_value
    grid.disable_cell_edit_control
    assert_equal("'hello world'", grid.get_cell_value(1, 1))

    unless is_ci_build? && is_macos?
      grid.set_grid_cursor([4, 3])
      grid.enable_cell_edit_control
      grid.get_cell_editor(4, 3).get_control.set_selection(1)
      grid.save_edit_control_value
      grid.disable_cell_edit_control
      assert_equal('bar', grid.get_cell_value(4, 3))
    end

    grid.set_grid_cursor([6, 0])
    grid.enable_cell_edit_control
    grid.get_cell_editor(6, 0).get_control.set_value(true)
    grid.save_edit_control_value
    grid.disable_cell_edit_control
    assert_equal('1', grid.get_cell_value(6, 0))
  end

end
