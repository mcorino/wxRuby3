# A data-oriented editable table control.
class Wx::Grids::Grid
  # The following extensions are all to prevent crashes associated with
  # garbage collection of Grid-related classes; they do not extend the
  # public functionality of the class in any way. 
  # 
  # GridTableBase, and the GridCellRenderers and GridCellEditors pose a
  # problem for ruby's GC, in that Wx makes them owned by the grid once
  # they have been set for a cell or group of cells. However, because
  # they might be SWIG directors we cannot allow the ruby object they are
  # originally associated with to be swept by GC, as C++ method calls
  # are routed to ruby method calls.
  #
  # The code below stores Ruby redefines all methods that may
  # potentially set a GridTableBase, Editor or Renderer, and stores a
  # reference to them in an instance variable, so they are not disposed
  # of when GC sweeps.
  
  # These all need to be set up as private methods which default to an
  # array. This can't be done in initialize b/c that may not be called
  # when a Grid is loaded from XRC

  def __defaults
    @__defaults ||= {}
  end
  private :__defaults

  def __named_type_info
    @__named_type_info ||= {}
  end
  private :__named_type_info

  def __all_cell_objects
    @__cell_objects ||= []
  end
  private :__all_cell_objects

  def __row_cell_objects(row)
    __all_cell_objects[row] ||= []
  end
  private :__row_cell_objects

  def __cell_objects(row, col)
    __row_cell_objects(row)[col] ||= {}
  end
  private :__cell_objects

  def __col_attrs
    @__col_attrs ||= []
  end
  private :__col_attrs

  def __row_attrs
    @__row_attrs ||= []
  end
  private :__row_attrs

  # Set a grid table base to provide data
  alias :__assign_table :assign_table
  def assign_table(table, sel_mode = GridSelectionModes::GridSelectCells)
    # we do not allow assigning another table; wxWidgets itself does not allow that anymore either
    # in AssignTable (SetTable still allows but we do not use that).
    # GridTableBase provides enough options to adjust to grid changes that there is no need.
    raise RuntimeError, 'Grid already has table assigned.' if @__grid_table
    __assign_table(table, sel_mode)
    @__grid_table = table
  end
  alias :set_table :assign_table
  alias :table= :assign_table

  # Store the renderers / editors associated with types, if used
  alias :__register_data_type :register_data_type
  def register_data_type(type_name, renderer, editor)
    __register_data_type(type_name, renderer, editor)
    __named_type_info[type_name] = {renderer: renderer, editor: editor}
  end

  # store default editor
  wx_set_default_editor = self.instance_method(:set_default_editor)
  define_method(:set_default_editor) do | editor |
    wx_set_default_editor.bind(self).call(editor)
    __defaults[:editor] = editor
  end

  # store default renderer
  wx_set_default_renderer = self.instance_method(:set_default_renderer)
  define_method(:set_default_renderer) do | renderer |
    wx_set_default_renderer.bind(self).call(renderer)
    __defaults[:renderer] = renderer
   end

  # store cell editors
  wx_set_cell_editor = self.instance_method(:set_cell_editor)
  define_method(:set_cell_editor) do | row, col, editor |
    wx_set_cell_editor.bind(self).call(row, col, editor)
    __cell_objects(row, col)[:editor] = editor
   end

  # store cell renderer
  wx_set_cell_renderer = self.instance_method(:set_cell_renderer)
  define_method(:set_cell_renderer) do | row, col, renderer |
    wx_set_cell_renderer.bind(self).call(row, col, renderer)
    __cell_objects(row, col)[:renderer] = renderer
  end

  # Store a cell attribute for a single cell
  wx_set_attr = self.instance_method(:set_attr)
  define_method(:set_attr) do | row, col, attr |
    wx_set_attr.bind(self).call(row, col, attr)
    __cell_objects(row, col)[:attr] = attr
  end

  # Store an editor and/or renderer for a whole column
  wx_set_col_attr = self.instance_method(:set_col_attr)
  define_method(:set_col_attr) do | col, attr |
    wx_set_col_attr.bind(self).call(col, attr)
    __col_attrs[col] = attr
  end

  # Store an editor and/or renderer for a whole row
  wx_set_row_attr = self.instance_method(:set_row_attr)
  define_method(:set_row_attr) do | row, attr |
    wx_set_row_attr.bind(self).call(row, attr)
    __row_attrs[row] = attr
  end

  # This and the following methods do a bit of book-keeping - as rows
  # and columns are deleted and inserted, the position of the columns
  # and rows with stored editors and renderers may move.
  alias :__insert_rows :insert_rows
  def insert_rows(pos = 0, num = 1, update_labels = true)
    __insert_rows(pos, num, update_labels)
    __row_attrs.insert(pos, *::Array.new(num, nil))
    __all_cell_objects.insert(pos, *::Array.new(num, []))
  end
  
  alias :__insert_cols :insert_cols
  def insert_cols(pos = 0, num = 1, update_labels = true)
    __insert_cols(pos, num, update_labels)
    __col_attrs.insert(pos, *::Array.new(num, nil))
    __all_cell_objects.each { |row| row.insert(pos, *::Array.new(num, [])) }
  end

  alias :__delete_rows :delete_rows
  def delete_rows(pos = 0, num = 1, update_labels = true)
    __delete_rows(pos, num, update_labels)
    __row_attrs.slice!(pos, num)
    __all_cell_objects.slice!(pos, num)
  end
 
  alias :__delete_cols :delete_cols
  def delete_cols(pos = 0, num = 1, update_labels = true)
    __delete_cols(pos, num, update_labels)
    __col_attrs.slice!(pos, num)
    __all_cell_objects.each { |row| row.slice!(pos, num) }
  end
end

class Wx::Grids::GridCellAttr

  alias :__set_editor :set_editor
  def set_editor(editor)
    __set_editor(editor)
    @__editor = editor
  end

  alias :__set_renderer :set_renderer
  def set_renderer(renderer)
    __set_renderer(renderer)
    @__renderer = renderer
  end

end
