# A set of buttons and controls attached to one edge of a Wx::Frame
class Wx::ToolBar
  # Generic method to add items, supporting positional and named
  # arguments
  ADD_ITEM_PARAMS = [ 
                      Wx::Parameter[ :bitmap2, Wx::NULL_BITMAP ],
                      Wx::Parameter[ :position, -1 ], 
                      Wx::Parameter[ :id, -1 ],
                      Wx::Parameter[ :label, "" ], 
                      Wx::Parameter[ :kind, Wx::ItemKind::ITEM_NORMAL ],
                      Wx::Parameter[ :short_help, "" ], 
                      Wx::Parameter[ :long_help, "" ], 
                      Wx::Parameter[ :client_data, nil ] ]
  
  def add_item(bitmap1, *mixed_args)

    begin
      args = Wx::args_as_list(ADD_ITEM_PARAMS, *mixed_args)
    rescue => err
      err.set_backtrace(caller)
      Kernel.raise err
    end

    bitmap2 = args.shift

    pos = args.shift
    args.insert(2, Wx.bitmap_to_bundle(bitmap1))
    args.insert(3, Wx.bitmap_to_bundle(bitmap2))

    # Call add_tool to append if default position
    if pos == -1
      add_tool(*args)
    else
      insert_tool(pos, *args)
    end
  end

  # Fix backward Bitmap(Bundle) compatibility for add_tool overloads
  wx_add_tool = self.instance_method(:add_tool)
  define_method(:add_tool) do |toolId, label, bitmap, *args|
    if !args.empty? && Wx::Bitmap === args.first || Wx::BitmapBundle === args.first
      bitmap2 = args.shift
      wx_add_tool.bind(self).call(toolId, label, Wx.bitmap_to_bundle(bitmap), Wx.bitmap_to_bundle(bitmap2), *args)
    else
      wx_add_tool.bind(self).call(toolId, label, Wx.bitmap_to_bundle(bitmap), *args)
    end
  end

  # Fix backward Bitmap(Bundle) compatibility for insert_tool
  wx_insert_tool = self.instance_method(:insert_tool)
  define_method(:insert_tool) do |pos, toolId, label, bitmap, *args|
    bitmap2 = args.shift
    wx_insert_tool.bind(self).call(pos, toolId, label, Wx.bitmap_to_bundle(bitmap), Wx.bitmap_to_bundle(bitmap2), *args)
  end

  # Fix backward Bitmap(Bundle) compatibility for add_check_tool
  wx_add_check_tool = self.instance_method(:add_check_tool)
  define_method(:add_check_tool) do |toolId, label, bitmap, *args|
    bitmap2 = args.shift
    wx_add_check_tool.bind(self).call(toolId, label, Wx.bitmap_to_bundle(bitmap), Wx.bitmap_to_bundle(bitmap2), *args)
  end

  # Fix backward Bitmap(Bundle) compatibility for add_radio_tool
  wx_add_radio_tool = self.instance_method(:add_radio_tool)
  define_method(:add_radio_tool) do |toolId, label, bitmap, *args|
    bitmap2 = args.shift
    wx_add_radio_tool.bind(self).call(toolId, label, Wx.bitmap_to_bundle(bitmap), Wx.bitmap_to_bundle(bitmap2), *args)
  end

  # Fix backward Bitmap(Bundle) compatibility for add_radio_tool
  wx_create_tool = self.instance_method(:create_tool)
  define_method(:create_tool) do |toolId, label, bitmap, *args|
    bitmap2 = args.shift
    wx_create_tool.bind(self).call(toolId, label, Wx.bitmap_to_bundle(bitmap), Wx.bitmap_to_bundle(bitmap2), *args)
  end

  # Fix backward Bitmap(Bundle) compatibility for set_tool_disabled_bitmap
  wx_set_tool_disabled_bitmap = self.instance_method(:set_tool_disabled_bitmap)
  define_method(:set_tool_disabled_bitmap) do |id, bitmap|
    wx_set_tool_disabled_bitmap.bind(self).call(id, Wx.bitmap_to_bundle(bitmap))
  end

  # Fix backward Bitmap(Bundle) compatibility for set_tool_normal_bitmap
  wx_set_tool_normal_bitmap = self.instance_method(:set_tool_normal_bitmap)
  define_method(:set_tool_normal_bitmap) do |id, bitmap|
    wx_set_tool_normal_bitmap.bind(self).call(id, Wx.bitmap_to_bundle(bitmap))
  end

end
