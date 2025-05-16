# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx::GRID

  GRID_VALUE_STRING = 'string'
  GRID_VALUE_BOOL = 'bool'
  GRID_VALUE_NUMBER = 'long'
  GRID_VALUE_FLOAT = 'double'
  GRID_VALUE_CHOICE = 'choice'
  GRID_VALUE_DATE = 'date'
  GRID_VALUE_TEXT = GRID_VALUE_STRING
  GRID_VALUE_LONG = GRID_VALUE_NUMBER
  
  class Grid

    alias :set_table :assign_table
    alias :table= :assign_table

    # Iterates all selected blocks passing each corresponding Wx::GRID::GridBlockCoords to the given block
    # or returns an enumerator if no block given.
    # Notice that the blocks returned by this method are not ordered in any particular way and may overlap.
    # For grids using rows or columns-only selection modes, #each_selected_row_block or #each_selected_col_block
    # can be more convenient, as they return ordered and non-overlapping blocks.
    # @overload each_selected_block(&block)
    #   @yieldparam [Wx::GRID::GridBlockCoords] selected_block
    #   @return [Object] result of last block execution
    # @overload each_selected_block()
    #   @return [Enumerator] enumerator
    def each_selected_block(*) end

    # Iterates an ordered range of non-overlapping selected rows passing each corresponding Wx::GRID::GridBlockCoords
    # to the given block or returns an enumerator if no block given.
    #
    # For the grids using GridSelectRows selection mode, iterates (possibly none) the coordinates of non-overlapping
    # selected row blocks in the natural order, i.e. from smallest to the biggest row indices.
    # @overload each_selected_row_block(&block)
    #   @yieldparam [Wx::GRID::GridBlockCoords] selected_block
    #   @return [Object] result of last block execution
    # @overload each_selected_row_block(&block)
    #   @return [Enumerator] enumerator
    def each_selected_row_block(*) end

    # Iterates an ordered range of non-overlapping selected columns passing each corresponding Wx::GRID::GridBlockCoords
    # to the given block or returns an enumerator if no block given.
    #
    # For the grids using GridSelectColumn selection mode, iterates (possibly none) the coordinates of non-overlapping
    # selected column blocks in the natural order, i.e. from smallest to the biggest column indices.
    # @overload each_selected_col_block(&block)
    #   @yieldparam [Wx::GRID::GridBlockCoords] selected_block
    #   @return [Object] result of last block execution
    # @overload each_selected_col_block(&block)
    #   @return [Enumerator] enumerator
    def each_selected_col_block(*) end

  end

  # Provides an opaque handle for grid windows.
  class GridWindow; end

end
