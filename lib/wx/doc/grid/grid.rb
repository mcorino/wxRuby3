
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

  end
  
end
