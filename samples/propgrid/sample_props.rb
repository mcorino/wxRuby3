###
# PropertyGrid sample custom properties
# Copyright (c) M.J.N. Corino, The Netherlands
###

class WxFontDataProperty < Wx::PG::FontProperty

  def initialize(label = Wx::PG::PG_LABEL, name = Wx::PG::PG_LABEL, value = Wx::FontData.new)
    super(label,name,value.get_initial_font)

    font = self.value_data.font

    value.set_chosen_font(font)

    value.colour = Wx::BLACK unless value.colour.ok?

    # Set initial value - should be done in a simpler way like this
    # (instead of calling SetValue) in derived (wxObject) properties.
    @value_wxFontData = Wx::Variant.new(value)

    # Add extra children.
    add_private_child(Wx::PG::ColourProperty.new("Colour", Wx::PG::PG_LABEL, value.colour))
  end

  def do_get_editor_class
    Wx::PG::PG_EDITOR_TEXT_CTRL_AND_BUTTON
  end

  def on_set_value
    if self.value_data.object?(Wx::FontData)
      # Set m_value to wxFont so that wxFontProperty methods will work
      # correctly.
      @value_wxFontData = self.value_data

      fontData = @value_wxFontData.object

      font = fontData.get_chosen_font
      font = Wx::FontInfo(10).family(Wx::FONTFAMILY_SWISS) unless font.ok?

      self.value_data = font
    else
      if self.value_data.font?
        font = self.value_data.font
        fontData = Wx::FontData.new
        fontData.set_chosen_font(font)
        unless @value_wxFontData.null?
          oldFontData = @value_wxFontData.object
          fontData.colour = oldFontData.colour
        else
          fontData.colour = Wx::BLACK
        end
        @value_wxFontData << fontData
      else
        raise "Value to wxFontDataProperty must be either wxFontData or wxFont"
      end
    end
  end

  # In order to have different value type in a derived property
  # class, we will override GetValue to return custom variant,
  # instead of changing the base m_value. This allows the methods
  # in base class to function properly.
  def do_get_value
    @value_wxFontData ||= Wx::Variant.new
  end

  def child_changed(thisValue, childIndex, childValue)
    fontData = thisValue.object
    fontData.initial_font = fontData.chosen_font

    case childIndex
    when 6
      col = childValue.colour
      fontData.colour = col
    else
      # Transfer from subset to superset.
      font = fontData.chosen_font
      variant = Wx::Variant.new(font)
      variant = super(variant, childIndex, childValue)
      font = variant.font
      fontData.chosen_font = font
    end

    Wx::Variant.new(fontData)
  end

  def refresh_children
    super
    return if get_child_count < 6    # Number is count of wxFontProperty's children + 1.
    fontData = @value_wxFontData.object
    variant = Wx::Variant.new(fontData.colour)
    item(6).value = variant
  end

  protected

  def display_editor_dialog(pg, value)
    raise "Function called for incompatible property" unless value.object?(Wx::FontData)

    fontData = value.object
    fontData.initial_font = fontData.chosen_font

    dlg = Wx::FontDialog.new(pg.panel, fontData)
    dlg_title = self.get_attribute(Wx::PG::PG_DIALOG_TITLE).string
    dlg.title = dlg_title unless dlg_title.empty?

    if dlg.show_modal == Wx::ID_OK
      fontData = dlg.get_font_data
      value << fontData
      return true
    end
    false
  end

end # FontDataProperty

class WxSizeProperty < Wx::PG::PGProperty

  def initialize(label = Wx::PG::PG_LABEL, name = Wx::PG::PG_LABEL, value = Wx::Size.new)
    super(label, name)
    set_value_i(value)
    add_private_child( Wx::PG::IntProperty.new("Width", Wx::PG::PG_LABEL,value.width))
    add_private_child( Wx::PG::IntProperty.new("Height", Wx::PG::PG_LABEL,value.height))
  end

  def child_changed(thisValue, childIndex, childValue)
    size = thisValue.object
    val = childValue.long
    case childIndex
    when 0
      size.width = val
    when 1
      size.height = val
    end
    Wx::Variant.new(size)
  end

  def refresh_children
    return unless child_count>0
    size = self.value.object
    item(0).value = Wx::Variant.new(size.width)
    item(1).value = Wx::Variant.new(size.height)
  end

  protected

  # I stands for internal
  def set_value_i(value)
    self.value = value
  end

end

class WxPointProperty < Wx::PG::PGProperty

  def initialize(label = Wx::PG::PG_LABEL, name = Wx::PG::PG_LABEL, value = Wx::Point.new)
    super(label, name)
    set_value_i(value);
    add_private_child( Wx::PG::IntProperty.new("X", Wx::PG::PG_LABEL,value.x))
    add_private_child( Wx::PG::IntProperty.new("Y", Wx::PG::PG_LABEL,value.y))
  end

  def child_changed(thisValue, childIndex, childValue)
    point = thisValue.object
    val = childValue.long
    case childIndex
    when 0
      point.x = val
    when 1
      point.y = val
    end
    Wx::Variant.new(point)
  end

  def refresh_children
    return unless child_count>0
    point = self.value.object
    item(0).value = Wx::Variant.new(point.x)
    item(1).value = Wx::Variant.new(point.y)
  end

  protected

  # I stands for internal
  def set_value_i(value)
    self.value = value
  end

end

class WxDirsProperty < Wx::PG::ArrayStringProperty
  def initialize(label = Wx::PG::PG_LABEL, name = Wx::PG::PG_LABEL, value = [])
    super
    self.set_attribute(Wx::PG::PG_ARRAY_DELIMITER, Wx::Variant.new(','))
    self.custom_btn_text = 'Browse'
  end

  def do_get_editor_class
    Wx::PG::PG_EDITOR_TEXT_CTRL_AND_BUTTON
  end

  def do_get_validator
    if Wx.has_feature?(:USE_VALIDATORS)
      Wx::PG::FileProperty.get_class_validator
    else
      nil
    end
  end

  def on_custom_string_edit(parent)
    dlg = Wx::DirDialog.new(parent,
                    "Select a directory to be added to the list:",
                            '',
                            0);

    if dlg.show_modal == Wx::ID_OK
      dlg.path
    else
      nil
    end
  end
end

class WxArrayDoubleProperty < Wx::PG::EditorDialogProperty

  class EditorDialog < Wx::PG::PGArrayEditorDialog
    def initialize
      super
      init
    end

    def init
      @precision = -1
    end

    def create(parent, message, caption, style = Wx::PG::AEDIALOG_STYLE, pos = Wx::DEFAULT_POSITION, sz = Wx::DEFAULT_SIZE)
      @array = array
      super(parent,message,caption,style,pos,sz)
    end

    attr_reader :array

    # Extra method for this type of array
    attr_accessor :precision

    def set_dialog_value(value)
      @array = value.object
    end

    def get_dialog_value
      Wx::Variant.new(@array)
    end

    protected

    # @param index [Integer]
    # @return [String]
    def array_get(index)
      "%#{@precision < 0 ? '' : ".#{@precision}"}f" % @array[index]
    end

    # @return [Integer]
    def array_get_count
      @array.size
    end

    # @param str [String]
    # @param index [Integer]
    # @return [true,false]
    def array_insert(str, index)
      if (v = Float(str) rescue nil)
        if index<0
          @array << v
        else
          @array.insert(index, v)
        end
      end
      !!v
    end

    # @param index [Integer]
    # @param str [String]
    # @return [true,false]
    def array_set(index, str)
      if (v = Float(str) rescue nil)
        @array[index] = v
      end
      !!v
    end

    # @param index [Integer]
    # @return [void]
    def array_remove_at(index)
      @array.delete_at(index)
    end

    # @param first [Integer]
    # @param second [Integer]
    # @return [void]
    def array_swap(first, second)
      old_first = @array[first]
      @array[first] = @array[second]
      @array[second] = old_first
    end
  end

  class << self
    def validator
      @validator
    end
    def validator=(obj)
      @validator = obj
    end
  end

  def initialize(label = Wx::PG::PG_LABEL, name = Wx::PG::PG_LABEL, value = [])
    super(label, name)
    @precision = -1
    self.dlg_style = Wx::PG::AEDIALOG_STYLE
    @delimiter = ';'
    @display = ''
    self.value = value
  end

  def generate_value_as_string(prec, removeZeroes)
    fmt = "%#{prec < 0 ? '' : ".#{prec}"}f"
    self.value.object.collect do |dbl|
      s = fmt % dbl
      if removeZeroes && prec != 0
        s.sub!(/(\d+\.[^0]*)0+\Z/, '\1')
        s.chomp!('.')
      end
      s
    end.join("#{@delimiter} ")
  end
  protected :generate_value_as_string

  def on_set_value
    @display = generate_value_as_string(@precision, true)
  end

  def do_get_editor_class
    Wx::PG::PG_EDITOR_TEXT_CTRL_AND_BUTTON
  end

  protected def display_editor_dialog(pg, value)
    unless value.object?(::Array) && value.object.all? { |e| ::Float === e }
      raise 'Function called for incompatible property'
    end

    dlg = EditorDialog.new
    dlg.set_dialog_value(value)
    dlg.precision = @precision
    dlg.create(pg.panel,
               '',
               self.dlg_title.empty? ? self.label : self.dlg_title,
               self.dlg_style)
    dlg.move(pg.get_good_editor_dialog_position(self, dlg.size))

    # Execute editor dialog
    res = dlg.show_modal
    if res == Wx::ID_OK && dlg.modified?
      value << dlg.get_dialog_value
      true
    else
      false
    end
  end

  def value_to_string(value, argFlags=0)
    if (argFlags & Wx::PG::PG_FULL_VALUE) != 0
      generate_value_as_string(-1,false)
    elsif value.object == self.value.object
      @display # Display cached string only if value truly matches m_value
    else
      generate_value_as_string(@precision,true)
    end
  end

  def string_to_value(variant, text, argFlags=0)
    new_array = text.split(@delimiter).collect do |s|
      begin
        Float(s)
      rescue
        return false
      end
    end

    if self.value.object != new_array
      variant << new_array
      true
    else
      false
    end
  end

  def do_set_attribute(name, value)
    if name == Wx::PG::PG_FLOAT_PRECISION
      @precision = value.long
      @display = generate_value_as_string(@precision, true)
      true
    else
      super
    end
  end

  def do_get_validator
    if Wx.has_feature?(:USE_VALIDATORS)
      unless WxArrayDoubleProperty.validator
        WxArrayDoubleProperty.validator =
          Wx::PG::NumericPropertyValidator.new(Wx::PG::NumericPropertyValidator::NumericType::Float)

        # Accept also a delimiter and space character
        WxArrayDoubleProperty.validator.add_char_includes(@delimiter)
        WxArrayDoubleProperty.validator.add_char_includes(' ')
      end
      WxArrayDoubleProperty.validator
    else
      nil
    end
  end

  def validate_value(value, validationInfo)
    unless value.object?(::Array) && value.object.all? { |e| ::Float === e }
      validationInfo.set_failure_message('At least one element is not a valid floating-point number.')
      false
    else
      true
    end
  end

end
