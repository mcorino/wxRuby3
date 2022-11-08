# A data-oriented editable table control.
class Wx::Grid::Grid
  # The following extensions are all to prevent crashes associated with
  # garbage collection of Grid-related classes; they do not extend the
  # public functionality of the class in any way. 
  # 
  # GridTableBase, and the GridCellRenderers and GridCellEditors pose a
  # problem for ruby's GC, in that Wx makes them owned by the grid once
  # they have been set for a cell or group of cells. However, because
  # they are SWIG directors we cannot allow the ruby object they are
  # originally associated with to be swept by GC, as C++ method calls
  # are routed to ruby method calls.
  #
  # The code below stores Ruby redefines all methods that may
  # potentially set a GridTableBase, Editor or Renderer, and stores a
  # reference to them in an instance variable, so they are not disposed
  # of up when GC sweeps.
  
  # These all need to be set up as private methods which default to an
  # array. This can't be done in initialize b/c that may not be called
  # when a Grid is loaded from XRC
  %w| __cell_attrs     __col_attrs     __row_attrs
      __cell_editors   __col_editors   __row_editors
      __cell_renderers __col_renderers __row_renderers |.each do | meth |
    define_method(meth) do
      instance_variable_get("@#{meth}") || 
        instance_variable_set("@#{meth}", [])
    end
    private meth
  end

  # Set a grid table base to provide data
  alias :__assign_table :assign_table
  def assign_table(table, sel_mode = Wx::Grid::Grid::GridSelectCells)
    # we do not allow assigning another table; wxWidgets itself does not allow that anymore either
    # in AssignTable (SetTable still allows but we do not use that).
    # GridTableBase provides enough options to adjust to grid changes that there is no need.
    raise RuntimeError, 'Grid already has table assigned.' if @__grid_table
    __assign_table(table, sel_mode)
    @__grid_table = table
  end
  alias :set_table :assign_table

  # Store the renderers / editors associated with types, if used
  alias :__register_data_type :register_data_type
  def register_data_type(type_name, renderer, editor)
    __register_data_type(type_name, renderer, editor)
    @__named_type_info ||= {}
    @__named_type_info[type_name] = [ renderer, editor ]
  end

  # store default editor
  wx_set_default_editor = self.instance_method(:set_default_editor)
  define_method(:set_default_editor) do | editr |
    wx_set_default_editor.bind(self).call(editr)
    @__default_editor = editr
  end

  # store default renderer
  wx_set_default_renderer = self.instance_method(:set_default_renderer)
  define_method(:set_default_renderer) do | rendr |
    wx_set_default_renderer.bind(self).call(rendr)
    @__default_renderer = rendr
   end

  # store cell editors
  wx_set_cell_editor = self.instance_method(:set_cell_editor)
  define_method(:set_cell_editor) do | row, col, editr |
    wx_set_cell_editor.bind(self).call(row, col, editr)
    __cell_editors[row] ||= []
    __cell_editors[row][col] = editr
   end

  # store cell renderer
  wx_set_cell_renderer = self.instance_method(:set_cell_renderer)
  define_method(:set_cell_renderer) do | row, col, rendr |
    wx_set_cell_renderer.bind(self).call(row, col, rendr)
    __cell_renderers[row] ||= []
    __cell_renderers[row][col] = rendr
  end

  # Store a cell attribute for a single cell
  wx_set_attr = self.instance_method(:set_attr)
  define_method(:set_attr) do | row, col, attr |
    wx_set_attr.bind(self).call(row, col, attr)
    (__cell_attrs[row] ||= [])[col] = attr
    if attr.has_editor
      (__cell_editors[row] ||= [])[col] = attr.get_editor(self, row, col)
    end
    if attr.has_renderer
      (__cell_renderers[row] ||= [])[col] = attr.get_renderer(self, row, col)
    end
  end

  # Store an editor and/or renderer for a whole column
  wx_set_col_attr = self.instance_method(:set_col_attr)
  define_method(:set_col_attr) do | col, attr |
    wx_set_col_attr.bind(self).call(col, attr)
    __col_attrs[col] = attr
    if attr.has_editor
      __col_editors[col] = attr.get_editor(self, 0, col)
    end
    if attr.has_renderer
      __col_renderers[col] = attr.get_renderer(self, 0, col)
    end
  end  

  # Store an editor and/or renderer for a whole row
  wx_set_row_attr = self.instance_method(:set_row_attr)
  define_method(:set_row_attr) do | row, attr |
    wx_set_row_attr.bind(self).call(row, attr)
    __row_attrs[col] = attr
    if attr.has_editor
      __row_editors[row] = attr.get_editor(self, row, 0)
    end
    if attr.has_renderer
      __row_renderers[row] = attr.get_renderer(self, row, 0)
    end
  end  

  # This and the following methods do a bit of book-keeping - as rows
  # and columns are deleted and inserted, the position of the columns
  # and rows with stored editors and renderers may move.
  alias :__insert_rows :insert_rows
  def insert_rows(pos = 0, num = 1, update_labels = true)
    __insert_rows(pos, num, update_labels)
    num.times { __row_attrs.insert(pos, nil) }
    num.times { __row_editors.insert(pos, nil) }
    num.times { __row_renderers.insert(pos, nil) }
    num.times { __cell_attrs.insert(pos, []) }
    num.times { __cell_editors.insert(pos, []) }
    num.times { __cell_renderers.insert(pos, []) }
  end
  
  alias :__insert_cols :insert_cols
  def insert_cols(pos = 0, num = 1, update_labels = true)
    __insert_cols(pos, num, update_labels)
    num.times { __col_attrs.insert(pos, nil) }
    num.times { __col_editors.insert(pos, nil) }
    num.times { __col_renderers.insert(pos, nil) }
    num.times do
      __cell_attrs.map { | col | col.insert(pos, []) if col }
    end
    num.times do
      __cell_editors.map { | col | col.insert(pos, []) if col }
    end
    num.times do
      __cell_renderers.map { | col | col.insert(pos, []) if col }
    end
  end

  alias :__delete_rows :delete_rows
  def delete_rows(pos = 0, num = 1, update_labels = true)
    __delete_rows(pos, num, update_labels)
    __row_attrs.slice!(pos, num)
    __row_editors.slice!(pos, num)
    __row_renderers.slice!(pos, num)
    __cell_attrs.slice!(pos, num)
    __cell_editors.slice!(pos, num)
    __cell_renderers.slice!(pos, num)
  end
 
  alias :__delete_cols :delete_cols
  def delete_cols(pos = 0, num = 1, update_labels = true)
    __delete_cols(pos, num, update_labels)
    __col_attrs.slice!(pos, num)
    __col_editors.slice!(pos, num)
    __col_renderers.slice!(pos, num)
    num.times do
      __cell_attrs.map { | col | col.slice!(pos, num) if col }
    end
    num.times do
      __cell_editors.map { | col | col.slice!(pos, num) if col }
    end
    num.times do
      __cell_renderers.map { | col | col.slice!(pos, num) if col }
    end
  end
end
