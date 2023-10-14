# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets richtext sample
# Copyright (c) Julian Smart

require 'wx'
require 'stringio'

# A custom field type
class RichTextFieldTypePropertiesTest < Wx::RTC::RichTextFieldTypeStandard

  def initialize(name, label_or_bmp, displayStyle = Wx::RTC::RICHTEXT_FIELD_STYLE_RECTANGLE)
    super(name, label_or_bmp, displayStyle)
  end

  def can_edit_properties(_obj); true; end

  def edit_properties(_obj, _parent, _buffer)
    label = get_label
    Wx.message_box("Editing #{label}")
    true
  end

  def get_properties_menu_label(_obj)
    get_label
  end

end

# A custom composite field type
class RichTextFieldTypeCompositeTest < RichTextFieldTypePropertiesTest

  def initialize(name, label)
    super(name, label, Wx::RTC::RICHTEXT_FIELD_STYLE_COMPOSITE)
  end

  def update_field(buffer, obj)
    if buffer
      attr = Wx::RTC::RichTextAttr.new(buffer.get_attributes)
      attr.get_text_box_attr.reset
      attr.set_paragraph_spacing_after(0)
      attr.set_line_spacing(10)
      obj.set_attributes(attr)
    end
    obj.delete_children
    para = Wx::RTC::RichTextParagraph.new
    text = Wx::RTC::RichTextPlainText.new(get_label)
    para.append_child(text)
    obj.append_child(para)
    true
  end

end

# ----------------------------------------------------------------------------
# private classes
# ----------------------------------------------------------------------------


class RichTextEnhancedDrawingHandler < Wx::RTC::RichTextDrawingHandler

  def initialize(name = nil)
    super("enhanceddrawing")
    @lockBackgroundColour = Wx::Colour.new(220, 220, 220)
  end

  # Returns @true if this object has virtual attributes that we can provide.
  def has_virtual_attributes(obj)
    obj.get_properties.has_property("Lock")
  end

  # Provides virtual attributes that we can provide.
  def get_virtual_attributes(attr, obj)
    if obj.get_properties.has_property("Lock")
      attr.set_background_colour(@lockBackgroundColour)
      true
    else
      false
    end
  end

  # Gets the count for mixed virtual attributes for individual positions within the object.
  # For example, individual characters within a text object may require special highlighting.
  def get_virtual_subobject_attributes_count(_obj); 0; end

  # Gets the mixed virtual attributes for individual positions within the object.
  # For example, individual characters within a text object may require special highlighting.
  # Returns the number of virtual attributes found.
  def get_virtual_subobject_attributes(_obj, _positions, _attributes); 0; end

  # Do we have virtual text for this object? Virtual text allows an application
  # to replace characters in an object for editing and display purposes, for example
  # for highlighting special characters.
  def has_virtual_text(_obj); false; end

  # Gets the virtual text for this object.
  def get_virtual_text(_obj, _text); false; end

end

# Define a new application type, each program should derive a class from wxApp
class MyRichTextCtrl < Wx::RTC::RichTextCtrl

  def initialize(parent, id: Wx::ID_ANY, value: '', pos: Wx::DEFAULT_POSITION, size: Wx::DEFAULT_SIZE,
                 style: Wx::RTC::RE_MULTILINE, validator: Wx::DEFAULT_VALIDATOR, name: 'myRichTextCtrl')
    super(parent, id: id, value: value, pos: pos, size: size, style: style, validator: validator, name: name)
    @lockId = 0
    @locked = false
  end

  attr_accessor :lockId

  def begin_lock; @lockId += 1; @locked = true; end
  def end_lock; @locked = false; end
  def is_locked?; @locked; end

  def self.set_enhanced_drawing_handler
    Wx::RTC::RichTextBuffer::add_drawing_handler(RichTextEnhancedDrawingHandler.new)
  end

  # Prepares the content just before insertion (or after buffer reset). Called by the same function in wxRichTextBuffer.
  # Currently is only called if undo mode is on.
  def prepare_content(container)
    if is_locked?
        # Lock all content that's about to be added to the control
        container.get_children.each do |child|
          if child.is_a?(Wx::RTC::RichTextParagraph)
            child.get_children.each do |obj|
              obj.get_properties.set_property("Lock", @lockId)
            end
          end
        end
    end
  end

  # Can we delete this range?
  # Sends an event to the control.
  def can_delete_range(container, range)
    Range.new(range.begin, range.end, true).each do |i|
      obj = container.get_leaf_object_at_position(i)
      return false if obj && obj.get_properties.has_property("Lock")
    end
    true
  end

  # Can we insert content at this position?
  # Sends an event to the control.
  def can_insert_content(container, pos)
    child1 = container.get_leaf_object_at_position(pos)
    child2 = container.get_leaf_object_at_position(pos-1)

    lock1 = lock2 = -1

    if child1 && child1.get_properties.has_property("Lock")
      lock1 = child1.get_properties.get_property_long("Lock")
    end
    if child2 && child2.get_properties.has_property("Lock")
      lock2 = child2.get_properties.get_property_long("Lock")
    end

    return false if lock1 != -1 && lock1 == lock2

    # Don't allow insertion before a locked object if it's at the beginning of the buffer.
    return false if pos == 0 && lock1 != -1

    true
  end

  # Finds a table,  either selected or near the cursor
  def find_table
    obj = find_current_position

    # It could be a table or a cell (or neither)
    if obj.is_a?(Wx::RTC::RichTextTable)
      return obj
    end

    while obj
      obj = obj.get_parent
      if obj.is_a?(Wx::RTC::RichTextTable)
        return obj
      end
    end

    nil
  end

  # Helper for FindTable()
  def find_current_position
    position = -1

    if has_selection  # First see if there's a selection
      range = get_selection_range
      if (range.size-1) == 1
        position = range.begin
      end
    end
    if position == -1  # Failing that, near cursor
      position = get_adjusted_caret_position(get_caret_position)
    end

    get_focus_object.get_leaf_object_at_position(position)
  end

end

# Define a new application type
class MyApp < Wx::App

  def initialize
    super
    @styleSheet = nil
    @printing =nil
  end

  # override base class virtuals
  # ----------------------------

  # this one is called on application startup and is a good place for the app
  # initialization (doing it here and not in the ctor allows to have an error
  # return: if on_init() returns false, the application terminates)
  def on_init

    if Wx.has_feature?(:USE_HELP)
      Wx::HelpProvider.set(Wx::SimpleHelpProvider.new)
    end

    @styleSheet = Wx::RTC::RichTextStyleSheet.new
    if Wx.has_feature?(:USE_PRINTING_ARCHITECTURE)
      @printing = Wx::RTC::RichTextPrinting.new("Test Document")

      @printing.set_footer_text("@TITLE@", Wx::RTC::RICHTEXT_PAGE_ALL, Wx::RTC::RICHTEXT_PAGE_CENTRE)
      @printing.set_footer_text("Page @PAGENUM@", Wx::RTC::RICHTEXT_PAGE_ALL, Wx::RTC::RICHTEXT_PAGE_RIGHT)
    end

    create_styles

    MyRichTextCtrl.set_enhanced_drawing_handler

    # Add extra handlers (plain text is automatically added)
    Wx::RTC::RichTextBuffer.add_handler(Wx::RTC::RichTextXMLHandler.new)
    Wx::RTC::RichTextBuffer.add_handler(Wx::RTC::RichTextHTMLHandler.new)

    # Add field types

    Wx::RTC::RichTextBuffer.add_field_type(RichTextFieldTypePropertiesTest.new("rectangle", "RECTANGLE", Wx::RTC::RichTextFieldTypeStandard::RICHTEXT_FIELD_STYLE_RECTANGLE))

    s1 = Wx::RTC::RichTextFieldTypeStandard.new("begin-section", "SECTION", Wx::RTC::RichTextFieldTypeStandard::RICHTEXT_FIELD_STYLE_START_TAG)
    s1.set_background_colour(Wx::BLUE)

    s2 = Wx::RTC::RichTextFieldTypeStandard.new("end-section", "SECTION", Wx::RTC::RichTextFieldTypeStandard::RICHTEXT_FIELD_STYLE_END_TAG)
    s2.set_background_colour(Wx::BLUE)

    s3 = Wx::RTC::RichTextFieldTypeStandard.new("bitmap", Wx.Bitmap(:paste), Wx::RTC::RichTextFieldTypeStandard::RICHTEXT_FIELD_STYLE_NO_BORDER)

    Wx::RTC::RichTextBuffer.add_field_type(s1)
    Wx::RTC::RichTextBuffer.add_field_type(s2)
    Wx::RTC::RichTextBuffer.add_field_type(s3)

    s4 = RichTextFieldTypeCompositeTest.new("composite", "This is a field value")
    Wx::RTC::RichTextBuffer.add_field_type(s4)

    if Wx.has_feature? :USE_FILESYSTEM
      Wx::FileSystem.add_handler(Wx::MemoryFSHandler.new)
    end

    # create the main application window
    size = Wx.get_display_size
    size.scale(0.75, 0.75)
    frame = MyFrame.new("Wx::RTC::RichTextCtrl Sample", size: size)

    if Wx.has_feature?(:USE_PRINTING_ARCHITECTURE)
      @printing.set_parent_window(frame)
    end

    # and show it (the frames, unlike simple controls, are not shown when
    # created initially)
    frame.show(true)

    # success: wxApp::OnRun() will be called which will enter the main message
    # loop and the application will run. If we returned false here, the
    # application would exit immediately.
    true
  end

  def create_styles
    # Paragraph styles

    romanFont = Wx::Font.new(Wx::FontInfo.new(12).family(Wx::FONTFAMILY_ROMAN))
    swissFont = Wx::Font.new(Wx::FontInfo.new(12).family(Wx::FONTFAMILY_SWISS))

    normalPara = Wx::RTC::RichTextParagraphStyleDefinition.new("Normal")
    normalAttr = Wx::RTC::RichTextAttr.new
    normalAttr.set_font_face_name(romanFont.get_face_name)
    normalAttr.set_font_size(12)
    # Let's set all attributes for this style
    normalAttr.set_flags(Wx::TEXT_ATTR_FONT | Wx::TEXT_ATTR_BACKGROUND_COLOUR | Wx::TEXT_ATTR_TEXT_COLOUR|Wx::TEXT_ATTR_ALIGNMENT|Wx::TEXT_ATTR_LEFT_INDENT|Wx::TEXT_ATTR_RIGHT_INDENT|Wx::TEXT_ATTR_TABS|
                            Wx::TEXT_ATTR_PARA_SPACING_BEFORE|Wx::TEXT_ATTR_PARA_SPACING_AFTER|Wx::TEXT_ATTR_LINE_SPACING|
                            Wx::TEXT_ATTR_BULLET_STYLE|Wx::TEXT_ATTR_BULLET_NUMBER)
    normalPara.set_style(normalAttr)

    @styleSheet.add_paragraph_style(normalPara)

    indentedPara = Wx::RTC::RichTextParagraphStyleDefinition.new("Indented")
    indentedAttr = Wx::RTC::RichTextAttr.new
    indentedAttr.set_font_face_name(romanFont.get_face_name)
    indentedAttr.set_font_size(12)
    indentedAttr.set_left_indent(100, 0)
    # We only want to affect indentation
    indentedAttr.set_flags(Wx::TEXT_ATTR_LEFT_INDENT|Wx::TEXT_ATTR_RIGHT_INDENT)
    indentedPara.set_style(indentedAttr)

    @styleSheet.add_paragraph_style(indentedPara)

    indentedPara2 = Wx::RTC::RichTextParagraphStyleDefinition.new("Red Bold Indented")
    indentedAttr2 = Wx::RTC::RichTextAttr.new
    indentedAttr2.set_font_face_name(romanFont.get_face_name)
    indentedAttr2.set_font_size(12)
    indentedAttr2.set_font_weight(Wx::FONTWEIGHT_BOLD)
    indentedAttr2.set_text_colour(Wx::RED)
    indentedAttr2.set_font_size(12)
    indentedAttr2.set_left_indent(100, 0)
    # We want to affect indentation, font and text colour
    indentedAttr2.set_flags(Wx::TEXT_ATTR_LEFT_INDENT|Wx::TEXT_ATTR_RIGHT_INDENT|Wx::TEXT_ATTR_FONT|Wx::TEXT_ATTR_TEXT_COLOUR)
    indentedPara2.set_style(indentedAttr2)

    @styleSheet.add_paragraph_style(indentedPara2)

    flIndentedPara = Wx::RTC::RichTextParagraphStyleDefinition.new("First Line Indented")
    flIndentedAttr = Wx::RTC::RichTextAttr.new
    flIndentedAttr.set_font_face_name(swissFont.get_face_name)
    flIndentedAttr.set_font_size(12)
    flIndentedAttr.set_left_indent(100, -100)
    # We only want to affect indentation
    flIndentedAttr.set_flags(Wx::TEXT_ATTR_LEFT_INDENT|Wx::TEXT_ATTR_RIGHT_INDENT)
    flIndentedPara.set_style(flIndentedAttr)

    @styleSheet.add_paragraph_style(flIndentedPara)

    # Character styles

    boldDef = Wx::RTC::RichTextCharacterStyleDefinition.new("Bold")
    boldAttr = Wx::RTC::RichTextAttr.new
    boldAttr.set_font_face_name(romanFont.get_face_name)
    boldAttr.set_font_size(12)
    boldAttr.set_font_weight(Wx::FONTWEIGHT_BOLD)
    # We only want to affect boldness
    boldAttr.set_flags(Wx::TEXT_ATTR_FONT_WEIGHT)
    boldDef.set_style(boldAttr)

    @styleSheet.add_character_style(boldDef)

    italicDef = Wx::RTC::RichTextCharacterStyleDefinition.new("Italic")
    italicAttr = Wx::RTC::RichTextAttr.new
    italicAttr.set_font_face_name(romanFont.get_face_name)
    italicAttr.set_font_size(12)
    italicAttr.set_font_style(Wx::FONTSTYLE_ITALIC)
    # We only want to affect italics
    italicAttr.set_flags(Wx::TEXT_ATTR_FONT_ITALIC)
    italicDef.set_style(italicAttr)

    @styleSheet.add_character_style(italicDef)

    redDef = Wx::RTC::RichTextCharacterStyleDefinition.new("Red Bold")
    redAttr = Wx::RTC::RichTextAttr.new
    redAttr.set_font_face_name(romanFont.get_face_name)
    redAttr.set_font_size(12)
    redAttr.set_font_weight(Wx::FONTWEIGHT_BOLD)
    redAttr.set_text_colour(Wx::RED)
    # We only want to affect colour, weight and face
    redAttr.set_flags(Wx::TEXT_ATTR_FONT_FACE|Wx::TEXT_ATTR_FONT_WEIGHT|Wx::TEXT_ATTR_TEXT_COLOUR)
    redDef.set_style(redAttr)

    @styleSheet.add_character_style(redDef)

    bulletList = Wx::RTC::RichTextListStyleDefinition.new("Bullet List 1")
    10.times do |i|
      if i == 0
        bulletText = "standard/circle"
      elsif i == 1
        bulletText = "standard/square"
      elsif i == 2
        bulletText = "standard/circle"
      elsif i == 3
        bulletText = "standard/square"
      else
        bulletText = "standard/circle"
      end
      bulletList.set_attributes(i, (i+1)*60, 60, Wx::TEXT_ATTR_BULLET_STYLE_STANDARD, bulletText)
    end

    @styleSheet.add_list_style(bulletList)

    numberedList = Wx::RTC::RichTextListStyleDefinition.new("Numbered List 1")
    10.times do |i|
      if i == 0
        numberStyle = Wx::TEXT_ATTR_BULLET_STYLE_ARABIC|Wx::TEXT_ATTR_BULLET_STYLE_PERIOD
      elsif i == 1
        numberStyle = Wx::TEXT_ATTR_BULLET_STYLE_LETTERS_LOWER|Wx::TEXT_ATTR_BULLET_STYLE_PARENTHESES
      elsif i == 2
        numberStyle = Wx::TEXT_ATTR_BULLET_STYLE_ROMAN_LOWER|Wx::TEXT_ATTR_BULLET_STYLE_PARENTHESES
      elsif i == 3
        numberStyle = Wx::TEXT_ATTR_BULLET_STYLE_ROMAN_UPPER|Wx::TEXT_ATTR_BULLET_STYLE_PARENTHESES
      else
        numberStyle = Wx::TEXT_ATTR_BULLET_STYLE_ARABIC|Wx::TEXT_ATTR_BULLET_STYLE_PERIOD
      end

      numberStyle |= Wx::TEXT_ATTR_BULLET_STYLE_ALIGN_RIGHT

      numberedList.set_attributes(i, (i+1)*60, 60, numberStyle)
    end

    @styleSheet.add_list_style(numberedList)

    outlineList = Wx::RTC::RichTextListStyleDefinition.new("Outline List 1")
    10.times do |i|
      if i < 4
        numberStyle = Wx::TEXT_ATTR_BULLET_STYLE_OUTLINE|Wx::TEXT_ATTR_BULLET_STYLE_PERIOD
      else
        numberStyle = Wx::TEXT_ATTR_BULLET_STYLE_ARABIC|Wx::TEXT_ATTR_BULLET_STYLE_PERIOD
      end

      outlineList.set_attributes(i, (i+1)*120, 120, numberStyle)
    end

    @styleSheet.add_list_style(outlineList)
  end

  def get_style_sheet
    @styleSheet
  end

  if Wx.has_feature?(:USE_PRINTING_ARCHITECTURE)

    def get_printing
      @printing
    end

  end
end


# Define a new frame type: this is going to be our main frame
class MyFrame < Wx::Frame
  
  # IDs for the controls and the menu commands
  module ID
    include Wx::IDHelper
    
    # menu items
    Quit = Wx::ID_EXIT
    About = Wx::ID_ABOUT

    FORMAT_BOLD = self.next_id
    FORMAT_ITALIC = self.next_id
    FORMAT_UNDERLINE = self.next_id
    FORMAT_STRIKETHROUGH = self.next_id
    FORMAT_SUPERSCRIPT = self.next_id
    FORMAT_SUBSCRIPT = self.next_id
    FORMAT_FONT = self.next_id
    FORMAT_IMAGE = self.next_id
    FORMAT_PARAGRAPH = self.next_id
    FORMAT_CONTENT = self.next_id

    RELOAD = self.next_id

    INSERT_SYMBOL = self.next_id
    INSERT_URL = self.next_id
    INSERT_IMAGE = self.next_id

    FORMAT_ALIGN_LEFT = self.next_id
    FORMAT_ALIGN_CENTRE = self.next_id
    FORMAT_ALIGN_RIGHT = self.next_id

    FORMAT_INDENT_MORE = self.next_id
    FORMAT_INDENT_LESS = self.next_id

    FORMAT_PARAGRAPH_SPACING_MORE = self.next_id
    FORMAT_PARAGRAPH_SPACING_LESS = self.next_id

    FORMAT_LINE_SPACING_HALF = self.next_id
    FORMAT_LINE_SPACING_DOUBLE = self.next_id
    FORMAT_LINE_SPACING_SINGLE = self.next_id

    FORMAT_NUMBER_LIST = self.next_id
    FORMAT_BULLETS_AND_NUMBERING = self.next_id
    FORMAT_ITEMIZE_LIST = self.next_id
    FORMAT_RENUMBER_LIST = self.next_id
    FORMAT_PROMOTE_LIST = self.next_id
    FORMAT_DEMOTE_LIST = self.next_id
    FORMAT_CLEAR_LIST = self.next_id

    TABLE_ADD_COLUMN = self.next_id
    TABLE_ADD_ROW = self.next_id
    TABLE_DELETE_COLUMN = self.next_id
    TABLE_DELETE_ROW = self.next_id

    SET_FONT_SCALE = self.next_id
    SET_DIMENSION_SCALE = self.next_id

    VIEW_HTML = self.next_id
    SWITCH_STYLE_SHEETS = self.next_id
    MANAGE_STYLES = self.next_id

    PRINT = self.next_id
    PREVIEW = self.next_id
    PAGE_SETUP = self.next_id

    RICHTEXT_CTRL = self.next_id
    RICHTEXT_STYLE_LIST = self.next_id
    RICHTEXT_STYLE_COMBO = self.next_id
  end
  
  # ctor(s)
  def initialize(title, id: Wx::ID_ANY, pos: Wx::DEFAULT_POSITION, size: Wx::DEFAULT_SIZE, style: Wx::DEFAULT_FRAME_STYLE)
    super(nil, id: id, pos: pos, size: size, style: style)

    @richTextCtrl = nil

    if Wx::PLATFORM == 'WXMAC'
      set_window_variant(Wx::WINDOW_VARIANT_SMALL)
    end

    self.icon = Wx::Icon.new(local_icon_file('../sample.xpm'))

    # create a menu bar
    fileMenu = Wx::Menu.new

    # the "About" item should be in the help menu
    helpMenu = Wx::Menu.new
    helpMenu.append(ID::About, "&About\tF1", "Show about dialog")

    fileMenu.append(Wx::ID_OPEN, "&Open\tCtrl+O", "Open a file")
    fileMenu.append(Wx::ID_SAVE, "&Save\tCtrl+S", "Save a file")
    fileMenu.append(Wx::ID_SAVEAS, "&Save As...\tF12", "Save to a new file")
    fileMenu.append_separator
    fileMenu.append(ID::RELOAD, "&Reload Text\tF2", "Reload the initial text")
    fileMenu.append_separator
    fileMenu.append(ID::PAGE_SETUP, "Page Set&up...", "Page setup")

    if Wx.has_feature? :USE_PRINTING_ARCHITECTURE
    fileMenu.append(ID::PRINT, "&Print...\tCtrl+P", "Print")
    fileMenu.append(ID::PREVIEW, "Print Pre&view", "Print preview")
    end

    fileMenu.append_separator
    fileMenu.append(ID::VIEW_HTML, "&View as HTML", "View HTML")
    fileMenu.append_separator
    fileMenu.append(ID::Quit, "E&xit\tAlt+X", "Quit this program")

    editMenu = Wx::Menu.new
    editMenu.append(Wx::ID_UNDO, "&Undo\tCtrl+Z")
    editMenu.append(Wx::ID_REDO, "&Redo\tCtrl+Y")
    editMenu.append_separator
    editMenu.append(Wx::ID_CUT, "Cu&t\tCtrl+X")
    editMenu.append(Wx::ID_COPY, "&Copy\tCtrl+C")
    editMenu.append(Wx::ID_PASTE, "&Paste\tCtrl+V")

    editMenu.append_separator
    editMenu.append(Wx::ID_SELECTALL, "Select A&ll\tCtrl+A")
    editMenu.append_separator
    editMenu.append(ID::SET_FONT_SCALE, "Set &Text Scale...")
    editMenu.append(ID::SET_DIMENSION_SCALE, "Set &Dimension Scale...")

    formatMenu = Wx::Menu.new
    formatMenu.append_check_item(ID::FORMAT_BOLD, "&Bold\tCtrl+B")
    formatMenu.append_check_item(ID::FORMAT_ITALIC, "&Italic\tCtrl+I")
    formatMenu.append_check_item(ID::FORMAT_UNDERLINE, "&Underline\tCtrl+U")
    formatMenu.append_separator
    formatMenu.append_check_item(ID::FORMAT_STRIKETHROUGH, "Stri&kethrough")
    formatMenu.append_check_item(ID::FORMAT_SUPERSCRIPT, "Superscrip&t")
    formatMenu.append_check_item(ID::FORMAT_SUBSCRIPT, "Subscrip&t")
    formatMenu.append_separator
    formatMenu.append_check_item(ID::FORMAT_ALIGN_LEFT, "L&eft Align")
    formatMenu.append_check_item(ID::FORMAT_ALIGN_RIGHT, "&Right Align")
    formatMenu.append_check_item(ID::FORMAT_ALIGN_CENTRE, "&Centre")
    formatMenu.append_separator
    formatMenu.append(ID::FORMAT_INDENT_MORE, "Indent &More")
    formatMenu.append(ID::FORMAT_INDENT_LESS, "Indent &Less")
    formatMenu.append_separator
    formatMenu.append(ID::FORMAT_PARAGRAPH_SPACING_MORE, "Increase Paragraph &Spacing")
    formatMenu.append(ID::FORMAT_PARAGRAPH_SPACING_LESS, "Decrease &Paragraph Spacing")
    formatMenu.append_separator
    formatMenu.append(ID::FORMAT_LINE_SPACING_SINGLE, "Normal Line Spacing")
    formatMenu.append(ID::FORMAT_LINE_SPACING_HALF, "1.5 Line Spacing")
    formatMenu.append(ID::FORMAT_LINE_SPACING_DOUBLE, "Double Line Spacing")
    formatMenu.append_separator
    formatMenu.append(ID::FORMAT_FONT, "&Font...")
    formatMenu.append(ID::FORMAT_IMAGE, "Image Property")
    formatMenu.append(ID::FORMAT_PARAGRAPH, "&Paragraph...")
    formatMenu.append(ID::FORMAT_CONTENT, "Font and Pa&ragraph...\tShift+Ctrl+F")
    formatMenu.append_separator
    formatMenu.append(ID::SWITCH_STYLE_SHEETS, "&Switch Style Sheets")
    formatMenu.append(ID::MANAGE_STYLES, "&Manage Styles")

    listsMenu = Wx::Menu.new
    listsMenu.append(ID::FORMAT_BULLETS_AND_NUMBERING, "Bullets and &Numbering...")
    listsMenu.append_separator
    listsMenu.append(ID::FORMAT_NUMBER_LIST, "Number List")
    listsMenu.append(ID::FORMAT_ITEMIZE_LIST, "Itemize List")
    listsMenu.append(ID::FORMAT_RENUMBER_LIST, "Renumber List")
    listsMenu.append(ID::FORMAT_PROMOTE_LIST, "Promote List Items")
    listsMenu.append(ID::FORMAT_DEMOTE_LIST, "Demote List Items")
    listsMenu.append(ID::FORMAT_CLEAR_LIST, "Clear List Formatting")

    tableMenu = Wx::Menu.new
    tableMenu.append(ID::TABLE_ADD_COLUMN, "&Add Column")
    tableMenu.append(ID::TABLE_ADD_ROW, "Add &Row")
    tableMenu.append(ID::TABLE_DELETE_COLUMN, "Delete &Column")
    tableMenu.append(ID::TABLE_DELETE_ROW, "&Delete Row")

    insertMenu = Wx::Menu.new
    insertMenu.append(ID::INSERT_SYMBOL, "&Symbol...\tCtrl+I")
    insertMenu.append(ID::INSERT_URL, "&URL...")
    insertMenu.append(ID::INSERT_IMAGE, "&Image...")

    # now append the freshly created menu to the menu bar...
    menuBar = Wx::MenuBar.new
    menuBar.append(fileMenu, "&File")
    menuBar.append(editMenu, "&Edit")
    menuBar.append(formatMenu, "F&ormat")
    menuBar.append(listsMenu, "&Lists")
    menuBar.append(tableMenu, "&Tables")
    menuBar.append(insertMenu, "&Insert")
    menuBar.append(helpMenu, "&Help")

    # ... and attach this menu bar to the frame
    set_menu_bar(menuBar)

    # create a status bar just for fun (by default with 1 pane only)
    # but don't create it on limited screen space (mobile device)
    is_pda = Wx::SystemSettings.get_screen_type <= Wx::SYS_SCREEN_PDA

    if Wx.has_feature? :USE_STATUSBAR
      unless is_pda
        create_status_bar(2)
        set_status_text("Welcome to wxRichTextCtrl!")
      end
    end

    sizer = Wx::VBoxSizer.new
    set_sizer(sizer)

    # On Mac, don't create a 'native' wxToolBar because small bitmaps are not supported by native
    # toolbars. On Mac, a non-native, small-bitmap toolbar doesn't show unless it is explicitly
    # managed, hence the use of sizers. In a real application, use larger icons for the main
    # toolbar to avoid the need for this workaround. Or, use the toolbar in a container window
    # as part of a more complex hierarchy, and the toolbar will automatically be non-native.

    Wx::SystemOptions.set_option("mac.toolbar.no-native", 1)

    toolBar = Wx::ToolBar.new(self, style: Wx::NO_BORDER|Wx::TB_FLAT|Wx::TB_NODIVIDER|Wx::TB_NOALIGN)

    sizer.add(toolBar, 0, Wx::EXPAND)

    toolBar.add_tool(Wx::ID_OPEN, '', Wx.Bitmap(:open), "Open")
    toolBar.add_tool(Wx::ID_SAVEAS, '', Wx.Bitmap(:save), "Save")
    toolBar.add_separator
    toolBar.add_tool(Wx::ID_CUT, '', Wx.Bitmap(:cut), "Cut")
    toolBar.add_tool(Wx::ID_COPY, '', Wx.Bitmap(:copy), "Copy")
    toolBar.add_tool(Wx::ID_PASTE, '', Wx.Bitmap(:paste), "Paste")
    toolBar.add_separator
    toolBar.add_tool(Wx::ID_UNDO, '', Wx.Bitmap(:undo), "Undo")
    toolBar.add_tool(Wx::ID_REDO, '', Wx.Bitmap(:redo), "Redo")
    toolBar.add_separator
    toolBar.add_check_tool(ID::FORMAT_BOLD, '', Wx.Bitmap(:bold), nil, "Bold")
    toolBar.add_check_tool(ID::FORMAT_ITALIC, '', Wx.Bitmap(:italic), nil, "Italic")
    toolBar.add_check_tool(ID::FORMAT_UNDERLINE, '', Wx.Bitmap(:underline), nil, "Underline")
    toolBar.add_separator
    toolBar.add_check_tool(ID::FORMAT_ALIGN_LEFT, '', Wx.Bitmap(:alignleft), nil, "Align Left")
    toolBar.add_check_tool(ID::FORMAT_ALIGN_CENTRE, '', Wx.Bitmap(:centre), nil, "Centre")
    toolBar.add_check_tool(ID::FORMAT_ALIGN_RIGHT, '', Wx.Bitmap(:alignright), nil, "Align Right")
    toolBar.add_separator
    toolBar.add_tool(ID::FORMAT_INDENT_LESS, '', Wx.Bitmap(:indentless), "Indent Less")
    toolBar.add_tool(ID::FORMAT_INDENT_MORE, '', Wx.Bitmap(:indentmore), "Indent More")
    toolBar.add_separator
    toolBar.add_tool(ID::FORMAT_FONT, '', Wx.Bitmap(:font), "Font")
    toolBar.add_separator

    combo = Wx::RTC::RichTextStyleComboCtrl.new(toolBar, ID::RICHTEXT_STYLE_COMBO, size: [160, -1], style: Wx::CB_READONLY)
    toolBar.add_control(combo)

    toolBar.realize

    splitter = Wx::SplitterWindow.new(self, style: Wx::SP_LIVE_UPDATE)
    sizer.add(splitter, 1, Wx::EXPAND)

    @richTextCtrl = MyRichTextCtrl.new(splitter, id: ID::RICHTEXT_CTRL, style: Wx::VSCROLL|Wx::HSCROLL) # /*|wxWANTS_CHARS*/)
    # @richTextCtrl = Wx::RTC::RichTextCtrl.new(splitter, id: ID::RICHTEXT_CTRL, style: Wx::VSCROLL|Wx::HSCROLL) # /*|wxWANTS_CHARS*/)
    # wxASSERT(!m_richTextCtrl.GetBuffer().GetAttributes().HasFontPixelSize())

    font = Wx::Font.new(Wx::FontInfo.new(12).family(Wx::FONTFAMILY_ROMAN))

    @richTextCtrl.set_font(font)

    # wxASSERT(!m_richTextCtrl.GetBuffer().GetAttributes().HasFontPixelSize())

    @richTextCtrl.set_margins(10, 10)

    @richTextCtrl.set_style_sheet(Wx.get_app.get_style_sheet)

    combo.set_style_sheet(Wx.get_app.get_style_sheet)
    combo.set_rich_text_ctrl(@richTextCtrl)
    combo.update_styles

    styleListCtrl = Wx::RTC::RichTextStyleListCtrl.new(splitter, ID::RICHTEXT_STYLE_LIST)

    display = Wx.get_display_size
    if is_pda && display.width < display.height
      splitter.split_horizontally(@richTextCtrl, styleListCtrl)
    else
      width = get_client_size.width * 4 / 5
      splitter.split_vertically(@richTextCtrl, styleListCtrl, width)
      splitter.set_sash_gravity(0.8)
    end

    layout

    splitter.update_size

    styleListCtrl.set_style_sheet(Wx.get_app.get_style_sheet)
    styleListCtrl.set_rich_text_ctrl(@richTextCtrl)
    styleListCtrl.update_styles

    # attach event handlers
    evt_menu(ID::Quit,  :on_quit)
    evt_menu(ID::About, :on_about)

    evt_menu(Wx::ID_OPEN,  :on_open)
    evt_menu(Wx::ID_SAVE,  :on_save)
    evt_menu(Wx::ID_SAVEAS,  :on_save_as)

    evt_menu(ID::FORMAT_BOLD,  :on_bold)
    evt_menu(ID::FORMAT_ITALIC,  :on_italic)
    evt_menu(ID::FORMAT_UNDERLINE,  :on_underline)

    evt_menu(ID::FORMAT_STRIKETHROUGH,  :on_strikethrough)
    evt_menu(ID::FORMAT_SUPERSCRIPT,  :on_superscript)
    evt_menu(ID::FORMAT_SUBSCRIPT,  :on_subscript)

    evt_update_ui(ID::FORMAT_BOLD,  :on_update_bold)
    evt_update_ui(ID::FORMAT_ITALIC,  :on_update_italic)
    evt_update_ui(ID::FORMAT_UNDERLINE,  :on_update_underline)

    evt_update_ui(ID::FORMAT_STRIKETHROUGH,  :on_update_strikethrough)
    evt_update_ui(ID::FORMAT_SUPERSCRIPT,  :on_update_superscript)
    evt_update_ui(ID::FORMAT_SUBSCRIPT,  :on_update_subscript)

    evt_menu(ID::FORMAT_ALIGN_LEFT,  :on_align_left)
    evt_menu(ID::FORMAT_ALIGN_CENTRE,  :on_align_centre)
    evt_menu(ID::FORMAT_ALIGN_RIGHT,  :on_align_right)

    evt_update_ui(ID::FORMAT_ALIGN_LEFT,  :on_update_align_left)
    evt_update_ui(ID::FORMAT_ALIGN_CENTRE,  :on_update_align_centre)
    evt_update_ui(ID::FORMAT_ALIGN_RIGHT,  :on_update_align_right)

    evt_menu(ID::FORMAT_FONT,  :on_font)
    evt_menu(ID::FORMAT_IMAGE, :on_image)
    evt_menu(ID::FORMAT_PARAGRAPH,  :on_paragraph)
    evt_menu(ID::FORMAT_CONTENT,  :on_format)
    evt_update_ui(ID::FORMAT_CONTENT,  :on_update_format)
    evt_update_ui(ID::FORMAT_FONT,  :on_update_format)
    evt_update_ui(ID::FORMAT_IMAGE, :on_update_image)
    evt_update_ui(ID::FORMAT_PARAGRAPH,  :on_update_format)
    evt_menu(ID::FORMAT_INDENT_MORE,  :on_indent_more)
    evt_menu(ID::FORMAT_INDENT_LESS,  :on_indent_less)

    evt_menu(ID::FORMAT_LINE_SPACING_HALF,  :on_line_spacing_half)
    evt_menu(ID::FORMAT_LINE_SPACING_SINGLE,  :on_line_spacing_single)
    evt_menu(ID::FORMAT_LINE_SPACING_DOUBLE,  :on_line_spacing_double)

    evt_menu(ID::FORMAT_PARAGRAPH_SPACING_MORE,  :on_paragraph_spacing_more)
    evt_menu(ID::FORMAT_PARAGRAPH_SPACING_LESS,  :on_paragraph_spacing_less)

    evt_menu(ID::RELOAD,  :on_reload)

    evt_menu(ID::INSERT_SYMBOL,  :on_insert_symbol)
    evt_menu(ID::INSERT_URL,  :on_insert_url)
    evt_menu(ID::INSERT_IMAGE, :on_insert_image)

    evt_menu(ID::FORMAT_NUMBER_LIST, :on_number_list)
    evt_menu(ID::FORMAT_BULLETS_AND_NUMBERING, :on_bullets_and_numbering)
    evt_menu(ID::FORMAT_ITEMIZE_LIST, :on_itemize_list)
    evt_menu(ID::FORMAT_RENUMBER_LIST, :on_renumber_list)
    evt_menu(ID::FORMAT_PROMOTE_LIST, :on_promote_list)
    evt_menu(ID::FORMAT_DEMOTE_LIST, :on_demote_list)
    evt_menu(ID::FORMAT_CLEAR_LIST, :on_clear_list)

    evt_menu(ID::TABLE_ADD_COLUMN, :on_table_add_column)
    evt_menu(ID::TABLE_ADD_ROW, :on_table_add_row)
    evt_menu(ID::TABLE_DELETE_COLUMN, :on_table_delete_column)
    evt_menu(ID::TABLE_DELETE_ROW, :on_table_delete_row)
    evt_update_ui_range(ID::TABLE_ADD_COLUMN, ID::TABLE_ADD_ROW, :on_table_focused_update_ui)
    evt_update_ui_range(ID::TABLE_DELETE_COLUMN, ID::TABLE_DELETE_ROW, :on_table_has_cells_update_ui)

    evt_menu(ID::VIEW_HTML, :on_view_html)
    evt_menu(ID::SWITCH_STYLE_SHEETS, :on_switch_stylesheets)
    evt_menu(ID::MANAGE_STYLES, :on_manage_styles)

    if Wx.has_feature? :USE_PRINTING_ARCHITECTURE
    evt_menu(ID::PRINT, :on_print)
    evt_menu(ID::PREVIEW, :on_preview)
    end
    evt_menu(ID::PAGE_SETUP, :on_page_setup)

    evt_text_url(Wx::ID_ANY, :on_url)
    evt_richtext_stylesheet_replacing(Wx::ID_ANY, :on_stylesheet_replacing)

    evt_menu(ID::SET_FONT_SCALE, :on_set_font_scale)
    evt_menu(ID::SET_DIMENSION_SCALE, :on_set_dimension_scale)

    write_initial_text
  end

  # utility function to find an icon relative to this ruby script
  def local_icon_file(icon_name)
    File.join(File.dirname(__FILE__), icon_name)
  end

  # event handlers
  def on_quit(_event)
    close(true)
  end

  def on_about(_event)
    msg = "This is a demo for Wx::RTC::RichTextCtrl, a control for editing styled text.\nOriginal code (c) Julian Smart, 2005\nAdapted for wxRuby3 (c) Martin JN Corino, 2023"
    Wx.message_box(msg, "About wxRichTextCtrl Sample", Wx::OK | Wx::ICON_INFORMATION, self)
  end

  def on_open(_event)
    fileTypes = []
    filter = Wx::RTC::RichTextBuffer.get_ext_wildcard(false, false, fileTypes)
    filter += "|" unless filter.empty?

    filter += "All files (*.*)|*.*"

    Wx.FileDialog(self, "Choose a filename",
                  '',
                  '',
                  filter,
                  Wx::FD_OPEN) do |dialog|
      if dialog.show_modal == Wx::ID_OK
        path1 = dialog.path

        unless path1.empty?
          filterIndex = dialog.get_filter_index
          fileType = filterIndex < fileTypes.size ? fileTypes[filterIndex] : Wx::RTC::RICHTEXT_TYPE_TEXT
          @richTextCtrl.load_file(path1, fileType)
        end
      end
    end
  end

  def on_save(event)
    if @richTextCtrl.get_filename.empty?
      on_save_as(event)
    else
      @richTextCtrl.save_file
    end
  end

  def on_save_as(_event)
    filter = Wx::RTC::RichTextBuffer.get_ext_wildcard(false, true)

    Wx.FileDialog(self, "Choose a filename", '', '', filter, Wx::FD_SAVE) do |dialog|

      if dialog.show_modal == Wx::ID_OK
        path1 = dialog.path

        unless path1.empty?
          Wx::BusyCursor.busy do
            start = Time.now

            @richTextCtrl.save_file(path1)

            td = Time.now-start
            Wx.log_debug("Saving took #{td}s")
            Wx.message_box("Saving took #{td}s")
          end
        end
      end
    end
  end

  def on_bold(_event)
    @richTextCtrl.apply_bold_to_selection
  end
  def on_italic(_event)
    @richTextCtrl.apply_italic_to_selection
  end
  def on_underline(_event)
    @richTextCtrl.apply_underline_to_selection
  end

  def on_strikethrough(_event)
    @richTextCtrl.apply_text_effect_to_selection(Wx::TEXT_ATTR_EFFECT_STRIKETHROUGH)
  end
  def on_superscript(_event)
    @richTextCtrl.apply_text_effect_to_selection(Wx::TEXT_ATTR_EFFECT_SUPERSCRIPT)
  end
  def on_subscript(_event)
    @richTextCtrl.apply_text_effect_to_selection(Wx::TEXT_ATTR_EFFECT_SUBSCRIPT)
  end

  def on_update_bold(event)
    event.check(@richTextCtrl.is_selection_bold)
  end
  def on_update_italic(event)
    event.check(@richTextCtrl.is_selection_italics)
  end
  def on_update_underline(event)
    event.check(@richTextCtrl.is_selection_underlined)
  end
  def on_update_strikethrough(event)
    event.check(@richTextCtrl.does_selection_have_text_effect_flag(Wx::TEXT_ATTR_EFFECT_STRIKETHROUGH))
  end
  def on_update_superscript(event)
    event.check(@richTextCtrl.does_selection_have_text_effect_flag(Wx::TEXT_ATTR_EFFECT_SUPERSCRIPT))
  end
  def on_update_subscript(event)
    event.check(@richTextCtrl.does_selection_have_text_effect_flag(Wx::TEXT_ATTR_EFFECT_SUBSCRIPT))
  end

  def on_align_left(_event)
    @richTextCtrl.apply_alignment_to_selection(Wx::TEXT_ALIGNMENT_LEFT)
  end
  def on_align_centre(_event)
    @richTextCtrl.apply_alignment_to_selection(Wx::TEXT_ALIGNMENT_CENTRE)
  end
  def on_align_right(_event)
    @richTextCtrl.apply_alignment_to_selection(Wx::TEXT_ALIGNMENT_RIGHT)
  end

  def on_update_align_left(event)
    event.check(@richTextCtrl.is_selection_aligned(Wx::TEXT_ALIGNMENT_LEFT))
  end
  def on_update_align_centre(event)
    event.check(@richTextCtrl.is_selection_aligned(Wx::TEXT_ALIGNMENT_CENTRE))
  end
  def on_update_align_right(event)
    event.check(@richTextCtrl.is_selection_aligned(Wx::TEXT_ALIGNMENT_RIGHT))
  end

  def on_indent_more(_event)
    attr = Wx::RichTextAttr.new
    attr.set_flags(Wx::TEXT_ATTR_LEFT_INDENT)

    if @richTextCtrl.get_style(@richTextCtrl.get_insertion_point, attr)
      range = @richTextCtrl.get_insertion_point..@richTextCtrl.get_insertion_point
      range = @richTextCtrl.selection_range if @richTextCtrl.has_selection

      attr.set_left_indent(attr.get_left_indent + 100)

      attr.set_flags(Wx::TEXT_ATTR_LEFT_INDENT)
      @richTextCtrl.set_style(range, attr)
    end
  end
  def on_indent_less(_event)
    attr = Wx::RichTextAttr.new
    attr.set_flags(Wx::TEXT_ATTR_LEFT_INDENT)

    if @richTextCtrl.get_style(@richTextCtrl.get_insertion_point, attr)
      range = @richTextCtrl.get_insertion_point..@richTextCtrl.get_insertion_point
      range = @richTextCtrl.selection_range if @richTextCtrl.has_selection

      if attr.get_left_indent > 0
        attr.set_left_indent([0, attr.get_left_indent - 100].max)

        @richTextCtrl.set_style(range, attr)
      end
    end
  end

  def on_font(_event)
    if @richTextCtrl.has_selection
      range = @richTextCtrl.selection_range
    else
      range = 0..(@richTextCtrl.last_position+1)
    end

    pages = Wx::RTC::RICHTEXT_FORMAT_FONT

    Wx::RTC.RichTextFormattingDialog(pages, self) do |formatDlg|
      formatDlg.set_options(Wx::RTC::RichTextFormattingDialog::Option_AllowPixelFontSize)
      formatDlg.get_style(@richTextCtrl, range)

      if formatDlg.show_modal == Wx::ID_OK
        formatDlg.apply_style(@richTextCtrl, range,
                              Wx::RTC::RICHTEXT_SETSTYLE_WITH_UNDO|
                                Wx::RTC::RICHTEXT_SETSTYLE_OPTIMIZE|
                                Wx::RTC::RICHTEXT_SETSTYLE_CHARACTERS_ONLY)
      end
    end
  end
  def on_image(_event)
    if @richTextCtrl.has_selection
      range = @richTextCtrl.selection_range
      if (range.begin...range.end).size == 1
        image = @richTextCtrl.get_focus_object.get_leaf_object_at_position(range.begin)
        if image.is_a?(Wx::RTC::RichTextImage)
          Wx::RTC.RichTextObjectPropertiesDialog(image, self) do |imageDlg|
            if imageDlg.show_modal == Wx::ID_OK
              imageDlg.apply_style(@richTextCtrl)
            end
          end
        end
      end
    end
  end
  def on_update_image(event)
    range = @richTextCtrl.selection_range
    if (range.begin...range.end).size == 1
      obj = @richTextCtrl.get_focus_object.get_leaf_object_at_position(range.begin)
      if obj && obj.is_a?(Wx::RTC::RichTextImage)
        event.enable(true)
        return
      end
    end

    event.enable(false)
  end

  def on_paragraph(_event)
    range = if @richTextCtrl.has_selection
              @richTextCtrl.selection_range
            else
              0..(@richTextCtrl.last_position + 1)
            end

    pages = Wx::RTC::RICHTEXT_FORMAT_INDENTS_SPACING|Wx::RTC::RICHTEXT_FORMAT_TABS|Wx::RTC::RICHTEXT_FORMAT_BULLETS

    Wx::RTC.RichTextFormattingDialog(pages, self) do |formatDlg|
      formatDlg.get_style(@richTextCtrl, range)

      formatDlg.apply_style(@richTextCtrl, range) if formatDlg.show_modal == Wx::ID_OK
    end
  end
  def on_format(_event)
    range = if @richTextCtrl.has_selection
              @richTextCtrl.selection_range
            else
              0..(@richTextCtrl.last_position + 1)
            end

    pages = Wx::RTC::RICHTEXT_FORMAT_FONT|Wx::RTC::RICHTEXT_FORMAT_INDENTS_SPACING|Wx::RTC::RICHTEXT_FORMAT_TABS|Wx::RTC::RICHTEXT_FORMAT_BULLETS

    Wx::RTC.RichTextFormattingDialog(pages, self) do |formatDlg|
      formatDlg.get_style(@richTextCtrl, range)

      formatDlg.apply_style(@richTextCtrl, range) if formatDlg.show_modal == Wx::ID_OK
    end
  end
  def on_update_format(event)
    event.enable(@richTextCtrl.has_selection)
  end

  def on_insert_symbol(_event)
    attr = Wx::RTC::RichTextAttr.new
    attr.set_flags(Wx::TEXT_ATTR_FONT)
    @richTextCtrl.get_style(@richTextCtrl.insertion_point, attr)

    currentFontName = ''
    currentFontName = attr.font.face_name if attr.has_font && attr.font.ok?

    # Don't set the initial font in the dialog (so the user is choosing
    # 'normal text', i.e. the current font) but do tell the dialog
    # what 'normal text' is.

    Wx::RTC.SymbolPickerDialog("*", '', currentFontName, self) do |dlg|
      if dlg.show_modal == Wx::ID_OK
        if dlg.has_selection
          insertionPoint = @richTextCtrl.insertion_point

          @richTextCtrl.write_text(dlg.get_symbol)

          unless dlg.use_normal_font
            font = Wx::Font.new(attr.font)
            font.set_face_name(dlg.font_name)
            attr.set_font(font)
            @richTextCtrl.set_style(insertionPoint, insertionPoint+1, attr)
          end
        end
      end
    end
  end

  def set_selection_spacing(flag, &block)
    attr = Wx::RTC::RichTextAttr.new
    attr.set_flags(flag)

    if @richTextCtrl.get_style(@richTextCtrl.insertion_point, attr)
      range = @richTextCtrl.insertion_point..@richTextCtrl.insertion_point
      range = @richTextCtrl.selection_range if @richTextCtrl.has_selection

      block.call(attr)

      attr.set_flags(flag)
      @richTextCtrl.set_style(range, attr)
    end
  end
  protected :set_selection_spacing

  def on_line_spacing_half(_event)
    set_selection_spacing(Wx::TEXT_ATTR_LINE_SPACING) { |attr| attr.set_line_spacing(15) }
  end
  def on_line_spacing_double(_event)
    set_selection_spacing(Wx::TEXT_ATTR_LINE_SPACING) { |attr| attr.set_line_spacing(20) }
  end
  def on_line_spacing_single(_event)
    set_selection_spacing(Wx::TEXT_ATTR_LINE_SPACING) { |attr| attr.set_line_spacing(0) } # you could also use 10
  end

  def on_paragraph_spacing_more(_event)
    set_selection_spacing(Wx::TEXT_ATTR_PARA_SPACING_AFTER) do |attr|
      attr.set_paragraph_spacing_after(attr.get_paragraph_spacing_after + 20)
    end
  end
  def on_paragraph_spacing_less(_event)
    set_selection_spacing(Wx::TEXT_ATTR_PARA_SPACING_AFTER) do |attr|
      if attr.get_paragraph_spacing_after >= 20
        attr.set_paragraph_spacing_after(attr.get_paragraph_spacing_after - 20)
      else
        attr.set_paragraph_spacing_after(0)
      end
    end
  end

  def on_number_list(_event)
    if @richTextCtrl.has_selection
      range = @richTextCtrl.selection_range
      @richTextCtrl.set_list_style(range, 'Numbered List 1', Wx::RTC::RICHTEXT_SETSTYLE_WITH_UNDO|Wx::RTC::RICHTEXT_SETSTYLE_RENUMBER)
    end
  end
  def on_bullets_and_numbering(_event)
    sheet = @richTextCtrl.get_style_sheet

    flags = Wx::RTC::RICHTEXT_ORGANISER_BROWSE_NUMBERING

    Wx::RTC.RichTextStyleOrganiserDialog(flags, sheet, @richTextCtrl, self, Wx::ID_ANY, 'Bullets and Numbering') do |dlg|
      if dlg.show_modal == Wx::ID_OK
        dlg.apply_style if dlg.get_selected_style_definition
      end
    end
  end
  def on_itemize_list(_event)
    if @richTextCtrl.has_selection
      range = @richTextCtrl.get_selection_range
      @richTextCtrl.set_list_style(range, 'Bullet List 1')
    end
  end
  def on_renumber_list(_event)
    if @richTextCtrl.has_selection
      range = @richTextCtrl.get_selection_range
      @richTextCtrl.number_list(range, nil, Wx::RTC::RICHTEXT_SETSTYLE_WITH_UNDO|Wx::RTC::RICHTEXT_SETSTYLE_RENUMBER)
    end
  end
  def on_promote_list(_event)
    if @richTextCtrl.has_selection
      range = @richTextCtrl.get_selection_range
      @richTextCtrl.promote_list(1, range, nil)
    end
  end
  def on_demote_list(_event)
    if @richTextCtrl.has_selection
      range = @richTextCtrl.get_selection_range
      @richTextCtrl.promote_list(-1, range, nil)
    end
  end
  def on_clear_list(_event)
    if @richTextCtrl.has_selection
      range = @richTextCtrl.get_selection_range
      @richTextCtrl.clear_list_style(range)
    end
  end

  def on_table_add_column(_event)
    table = @richTextCtrl.find_table
    if table.is_a?(Wx::RTC::RichTextTable)
      cellAttr = table.get_cell(0, 0).attributes
      table.add_columns(table.column_count, 1, cellAttr)
    end
  end
  def on_table_add_row(_event)
    table = @richTextCtrl.find_table
    if table.is_a?(Wx::RTC::RichTextTable)
      cellAttr = table.get_cell(0, 0).attributes
      table.add_rows(table.row_count, 1, cellAttr)
    end
  end
  def on_table_delete_column(_event)
    table = @richTextCtrl.find_table
    if table.is_a?(Wx::RTC::RichTextTable)
      _, col = table.get_focused_cell
      col = table.column_count-1 if col == -1
      table.delete_columns(col, 1)
    end
  end
  def on_table_delete_row(_event)
    table = @richTextCtrl.find_table
    if table.is_a?(Wx::RTC::RichTextTable)
      row, _ = table.get_focused_cell
      row = table.row_count-1 if row == -1
      table.delete_rows(row, 1)
    end
  end
  def on_table_focused_update_ui(event)
    event.enable(@richTextCtrl.find_table != nil)
  end
  def on_table_has_cells_update_ui(event)
    enable = false
    table = @richTextCtrl.find_table
    if table.is_a?(Wx::RTC::RichTextTable)
        if event.id == ID::TABLE_DELETE_COLUMN
          enable = table.column_count > 1
        else
          enable = table.row_count > 1
        end
    end
    event.enable(enable)
  end

  def on_reload(_event)
    @richTextCtrl.clear
    write_initial_text
  end

  def on_view_html(_event)
    dialog = Wx::Dialog.new(self, Wx::ID_ANY, 'HTML', Wx::DEFAULT_POSITION, [500, 400], Wx::DEFAULT_DIALOG_STYLE)
    begin
      boxSizer = Wx::VBoxSizer.new
      dialog.set_sizer(boxSizer)

      win = Wx::HTML::HtmlWindow.new(dialog, size: [500, 400], style: Wx::SUNKEN_BORDER)
      boxSizer.add(win, 1, Wx::ALL, 5)

      cancelButton = Wx::Button.new(dialog, Wx::ID_CANCEL, '&Close')
      boxSizer.add(cancelButton, 0, Wx::ALL|Wx::CENTRE, 5)

      strStream = StringIO.new

      htmlHandler = Wx::RTC::RichTextHTMLHandler.new
      htmlHandler.set_flags(Wx::RTC::RICHTEXT_HANDLER_SAVE_IMAGES_TO_MEMORY)

      fontSizeMapping = [7,9,11,12,14,22,100]

      htmlHandler.set_font_size_mapping(fontSizeMapping)

      if htmlHandler.save_file(@richTextCtrl.buffer, strStream)
        strStream.rewind
        win.set_page(strStream.read || '')
      end

      boxSizer.fit(dialog)

      dialog.show_modal

      # Now delete the temporary in-memory images
      htmlHandler.delete_temporary_images
    ensure
      dialog.destroy
    end
  end

  class << self
    def alternate_style_sheet
      @alternate_style_sheet
    end
    def alternate_style_sheet=(alt)
      @alternate_style_sheet = alt
    end
  end

  # Demonstrates how you can change the style sheets and have the changes
  # reflected in the control content without wiping out character formatting.
  def on_switch_stylesheets(_event)
    styleList = find_window_by_id(ID::RICHTEXT_STYLE_LIST)
    styleCombo = find_window_by_id(ID::RICHTEXT_STYLE_COMBO)

    sheet = @richTextCtrl.get_style_sheet

    # One-time creation of an alternate style sheet
    unless MyFrame.alternate_style_sheet
      MyFrame.alternate_style_sheet = Wx::RTC::RichTextStyleSheet.new(sheet)

      # Make some modifications
      MyFrame.alternate_style_sheet.paragraph_style_count.times do |i|
        style_def = MyFrame.alternate_style_sheet.get_paragraph_style(i)

        style_def.get_style.set_text_colour(:BLUE) if style_def.get_style.has_text_colour

        if style_def.get_style.has_alignment
          if style_def.get_style.get_alignment == Wx::TEXT_ALIGNMENT_CENTRE
            style_def.get_style.set_alignment(Wx::TEXT_ALIGNMENT_RIGHT)
          elsif style_def.get_style.get_alignment == Wx::TEXT_ALIGNMENT_LEFT
            style_def.get_style.set_alignment(Wx::TEXT_ALIGNMENT_CENTRE)
          end
        end
        if style_def.get_style.has_left_indent
          style_def.get_style.set_left_indent(style_def.get_style.get_left_indent * 2)
        end
      end
    end

    # Switch sheets
    tmp = MyFrame.alternate_style_sheet
    MyFrame.alternate_style_sheet = sheet
    sheet = tmp

    @richTextCtrl.set_style_sheet(sheet)
    @richTextCtrl.apply_style_sheet(sheet) # Makes the control reflect the new style definitions

    styleList.set_style_sheet(sheet)
    styleList.update_styles

    styleCombo.set_style_sheet(sheet)
    styleCombo.update_styles
  end
  def on_manage_styles(_event)
    sheet = @richTextCtrl.get_style_sheet

    flags = Wx::RTC::RICHTEXT_ORGANISER_CREATE_STYLES|Wx::RTC::RICHTEXT_ORGANISER_EDIT_STYLES

    Wx::RTC.RichTextStyleOrganiserDialog(flags, sheet, nil, self, Wx::ID_ANY, 'Style Manager')
  end

  def on_insert_url(_event)
    url = Wx.get_text_from_user('URL:', 'Insert URL')
    unless url.empty?
      # Make a style suitable for showing a URL
      urlStyle = Wx::RichTextAttr.new
      urlStyle.set_text_colour(:BLUE)
      urlStyle.set_font_underlined(true)

      @richTextCtrl.begin_style(urlStyle)
      @richTextCtrl.begin_url(url)
      @richTextCtrl.write_text(url)
      @richTextCtrl.end_url
      @richTextCtrl.end_style
    end
  end
  def on_url(event)
    Wx.message_box(event.get_string)
  end
  def on_stylesheet_replacing(event)
    event.veto
  end

  if Wx.has_feature? :USE_PRINTING_ARCHITECTURE

  def on_print(_event)
    Wx.get_app.get_printing.print_buffer(@richTextCtrl.buffer)
  end
  def on_preview(_event)
    Wx.get_app.get_printing.preview_buffer(@richTextCtrl.buffer)
  end

  end

  def on_page_setup(_event)
    # dialog = Wx::Dialog.new(self, Wx::ID_ANY, 'Testing', [10, 10], [400, 300], Wx::DEFAULT_DIALOG_STYLE)
    # begin
    #   nb = Wx::Notebook.new(dialog, pos: [5, 5], size: [300, 250])
    #   panel = Wx::Panel.new(nb)
    #   panel2 = Wx::Panel.new(nb)
    #
    #   Wx::RichTextCtrl.new(panel, pos: [5, 5], size: [200, 150], style: Wx::VSCROLL|Wx::TE_READONLY)
    #   nb.add_page(panel, 'Page 1')
    #
    #   Wx::RichTextCtrl.new(panel2, pos: [5, 5], size: [200, 150], style: Wx::VSCROLL|Wx::TE_READONLY)
    #   nb.add_page(panel2, 'Page 2')
    #
    #   Wx::Button.new(dialog, Wx::ID_OK, 'OK', [5, 180])
    #
    #   dialog.show_modal
    # ensure
    #   dialog.destroy
    # end
    Wx.get_app.get_printing.page_setup
  end

  def on_insert_image(_event)
    Wx.FileDialog(self, 'Choose an image', '', '',
                  'BMP and GIF files (*.bmp;*.gif)|*.bmp;*.gif|PNG files (*.png)|*.png|JPEG files (*.jpg;*.jpeg)|*.jpg;*.jpeg') do |dialog|
      if dialog.show_modal == Wx::ID_OK
        path = dialog.path
        image = Wx::Image.new
        if image.load_file(path) && image.type != Wx::BITMAP_TYPE_INVALID
          @richTextCtrl.write_image(path, image.type)
        end
      end
    end
  end

  def on_set_font_scale(_event)
    value = "%g" % @richTextCtrl.get_font_scale
    text = Wx.get_text_from_user('Enter a text scale factor:', 'Text Scale Factor', value, Wx.get_top_level_parent(self))
    if !text.empty? && value != text
      scale = text.to_f
      scale = 1.0 if scale == 0.0
      @richTextCtrl.set_font_scale(scale, true)
    end
  end
  def on_set_dimension_scale(_event)
    value = "%g" % @richTextCtrl.get_dimension_scale
    text = Wx.get_text_from_user('Enter a dimension scale factor:', 'Dimension Scale Factor', value, Wx.get_top_level_parent(self))
    if !text.empty? && value != text
      scale = text.to_f
      scale = 1.0 if scale == 0.0
      @richTextCtrl.set_dimension_scale(scale, true)
    end
  end

  protected

  class << self

    def event_type
      @event_type ||= 0
    end
    def event_type=(v)
      @event_type = v
    end

    def win_id
      @win_id ||= 0
    end
    def win_id=(id)
      @win_id = id.to_i
    end

  end

  # Forward command events to the current rich text control, if any
  def try_before(event)
    if event.is_command_event && !event.is_a?(Wx::ChildFocusEvent)
      # Problem: we can get infinite recursion because the events
      # climb back up to this frame, and repeat.
      # Assume that command events don't cause another command event
      # to be called, so we can rely on inCommand not being overwritten

      if MyFrame.win_id != event.id && MyFrame.event_type != event.event_type
        MyFrame.event_type = event.event_type
        MyFrame.win_id = event.id
        focusWin = Wx.find_focus_descendant(self)
        focusWin = @richTextCtrl unless focusWin

        if focusWin && focusWin.get_event_handler.process_event(event)
          MyFrame.event_type = 0
          MyFrame.win_id = 0
          return true
        end

        MyFrame.event_type = 0
        MyFrame.win_id = 0
      else
        return false
      end
    end

    false
  end

  # Write text
  def write_initial_text
    r = @richTextCtrl

    r.set_default_style(Wx::RichTextAttr.new)

    r.freeze

    r.begin_suppress_undo

    r.begin_paragraph_spacing(0, 20)

    r.begin_alignment(Wx::TEXT_ALIGNMENT_CENTRE)
    r.begin_bold

    r.begin_font_size(14)

    lineBreak = ?\n

    r.write_text("Welcome to wxRichTextCtrl, a wxWidgets control" + lineBreak + "for editing and presenting styled text and images\n")
    r.end_font_size

    r.begin_italic
    r.write_text("by Julian Smart")
    r.end_italic

    r.end_bold
    r.newline

    r.write_image(Wx.Bitmap(:zebra))

    r.newline
    r.newline

    r.end_alignment

=begin
    r.begin_alignment(wxTEXT_ALIGNMENT_CENTRE)
    r.write_text("This is a simple test for a floating left image test. The zebra image should be placed at the left side of the current buffer and all the text should flow around it at the right side. This is a simple test for a floating left image test. The zebra image should be placed at the left side of the current buffer and all the text should flow around it at the right side. This is a simple test for a floating left image test. The zebra image should be placed at the left side of the current buffer and all the text should flow around it at the right side.")
    r.newline
    r.end_alignment
=end

    r.begin_alignment(Wx::TEXT_ALIGNMENT_LEFT)
    imageAttr = Wx::RTC::RichTextAttr.new
    imageAttr.get_text_box_attr.set_float_mode(Wx::TEXT_BOX_ATTR_FLOAT_LEFT)
    r.write_text("This is a simple test for a floating left image test. The zebra image should be placed at the left side of the current buffer and all the text should flow around it at the right side. This is a simple test for a floating left image test. The zebra image should be placed at the left side of the current buffer and all the text should flow around it at the right side. This is a simple test for a floating left image test. The zebra image should be placed at the left side of the current buffer and all the text should flow around it at the right side.")
    r.write_image(Wx.Bitmap(:zebra), Wx::BITMAP_TYPE_PNG, imageAttr)

    imageAttr.get_text_box_attr.top.set_value(200)
    imageAttr.get_text_box_attr.top.set_units(Wx::TEXT_ATTR_UNITS_PIXELS)
    imageAttr.get_text_box_attr.set_float_mode(Wx::TEXT_BOX_ATTR_FLOAT_RIGHT)
    r.write_image(Wx.Bitmap(:zebra), Wx::BITMAP_TYPE_PNG, imageAttr)
    r.write_text("This is a simple test for a floating right image test. The zebra image should be placed at the right side of the current buffer and all the text should flow around it at the left side. This is a simple test for a floating left image test. The zebra image should be placed at the right side of the current buffer and all the text should flow around it at the left side. This is a simple test for a floating left image test. The zebra image should be placed at the right side of the current buffer and all the text should flow around it at the left side.")
    r.end_alignment
    r.newline

    r.write_text("What can you do with this thing? ")

    r.write_image(Wx.Bitmap(:smiley))
    r.write_text(" Well, you can change text ")

    r.begin_text_colour(Wx::RED)
    r.write_text("colour, like this red bit.")
    r.end_text_colour

    backgroundColourAttr = Wx::RTC::RichTextAttr.new
    backgroundColourAttr.set_background_colour(Wx::GREEN)
    backgroundColourAttr.set_text_colour(:BLUE)
    r.begin_style(backgroundColourAttr)
    r.write_text(" And this blue on green bit.")
    r.end_style

    r.write_text(" Naturally you can make things ")
    r.begin_bold
    r.write_text("bold ")
    r.end_bold
    r.begin_italic
    r.write_text("or italic ")
    r.end_italic
    r.begin_underline
    r.write_text("or underlined.")
    r.end_underline

    r.begin_font_size(14)
    r.write_text(" Different font sizes on the same line is allowed, too.")
    r.end_font_size

    r.write_text(" Next we'll show an indented paragraph.")

    r.newline

    r.begin_left_indent(60)
    r.write_text("It was in January, the most down-trodden month of an Edinburgh winter. An attractive woman came into the cafe, which is nothing remarkable.")
    r.newline

    r.end_left_indent

    r.write_text("Next, we'll show a first-line indent, achieved using BeginLeftIndent(100, -40).")

    r.newline

    r.begin_left_indent(100, -40)

    r.write_text("It was in January, the most down-trodden month of an Edinburgh winter. An attractive woman came into the cafe, which is nothing remarkable.")
    r.newline

    r.end_left_indent

    r.write_text("Numbered bullets are possible, again using subindents:")
    r.newline

    r.begin_numbered_bullet(1, 100, 60)
    r.write_text("This is my first item. Note that wxRichTextCtrl can apply numbering and bullets automatically based on list styles, but this list is formatted explicitly by setting indents.")
    r.newline
    r.end_numbered_bullet

    r.begin_numbered_bullet(2, 100, 60)
    r.write_text("This is my second item.")
    r.newline
    r.end_numbered_bullet

    r.write_text("The following paragraph is right-indented:")
    r.newline

    r.begin_right_indent(200)

    r.write_text("It was in January, the most down-trodden month of an Edinburgh winter. An attractive woman came into the cafe, which is nothing remarkable.")
    r.newline

    r.end_right_indent

    r.write_text("The following paragraph is right-aligned with 1.5 line spacing:")
    r.newline

    r.begin_alignment(Wx::TEXT_ALIGNMENT_RIGHT)
    r.begin_line_spacing(Wx::TEXT_ATTR_LINE_SPACING_HALF)
    r.write_text("It was in January, the most down-trodden month of an Edinburgh winter. An attractive woman came into the cafe, which is nothing remarkable.")
    r.newline
    r.end_line_spacing
    r.end_alignment

    tabs = [400, 600, 800, 1000]
    attr = Wx::RichTextAttr.new
    attr.set_flags(Wx::TEXT_ATTR_TABS)
    attr.set_tabs(tabs)
    r.set_default_style(attr)

    r.write_text("This line contains tabs:\tFirst tab\tSecond tab\tThird tab")
    r.newline

    r.write_text("Other notable features of wxRichTextCtrl include:")
    r.newline

    r.begin_symbol_bullet('*', 100, 60)
    r.write_text("Compatibility with wxTextCtrl API")
    r.newline
    r.end_symbol_bullet

    r.begin_symbol_bullet('*', 100, 60)
    r.write_text("Easy stack-based BeginXXX()...EndXXX() style setting in addition to SetStyle()")
    r.newline
    r.end_symbol_bullet

    r.begin_symbol_bullet('*', 100, 60)
    r.write_text("XML loading and saving")
    r.newline
    r.end_symbol_bullet

    r.begin_symbol_bullet('*', 100, 60)
    r.write_text("Undo/Redo, with batching option and Undo suppressing")
    r.newline
    r.end_symbol_bullet

    r.begin_symbol_bullet('*', 100, 60)
    r.write_text("Clipboard copy and paste")
    r.newline
    r.end_symbol_bullet

    r.begin_symbol_bullet('*', 100, 60)
    r.write_text("wxRichTextStyleSheet with named character and paragraph styles, and control for applying named styles")
    r.newline
    r.end_symbol_bullet

    r.begin_symbol_bullet('*', 100, 60)
    r.write_text("A design that can easily be extended to other content types, ultimately with text boxes, tables, controls, and so on")
    r.newline
    r.end_symbol_bullet

    # Make a style suitable for showing a URL
    urlStyle = Wx::RichTextAttr.new
    urlStyle.set_text_colour(:BLUE)
    urlStyle.set_font_underlined(true)

    r.write_text("wxRichTextCtrl can also display URLs, such as this one: ")
    r.begin_style(urlStyle)
    r.begin_url("http:#www.wxwidgets.org")
    r.write_text("The wxWidgets Web Site")
    r.end_url
    r.end_style
    r.write_text(". Click on the URL to generate an event.")

    r.newline

    r.write_text("Note: this sample content was generated programmatically from within the MyFrame constructor in the demo. The images were loaded from inline XPMs. Enjoy wxRichTextCtrl!\n")

    r.end_paragraph_spacing
    
    # Add a text box

    r.newline

    attr1 = Wx::RichTextAttr.new
    attr1.get_text_box_attr.margins.left.set_value(20, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.top.set_value(20, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.right.set_value(20, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.bottom.set_value(20, Wx::TEXT_ATTR_UNITS_PIXELS)

    attr1.get_text_box_attr.border.set_colour(:BLACK)
    attr1.get_text_box_attr.border.set_width(1, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.border.set_style(Wx::TEXT_BOX_ATTR_BORDER_SOLID)

    textBox = r.write_text_box(attr1)
    r.set_focus_object(textBox)

    r.write_text("This is a text box. Just testing! Once more unto the breach, dear friends, once more...")

    r.set_focus_object(nil) # Set the focus back to the main buffer
    r.set_insertion_point_end
    
    # Add a table

    r.newline

    attr1 = Wx::RichTextAttr.new
    attr1.get_text_box_attr.margins.left.set_value(5, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.top.set_value(5, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.right.set_value(5, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.bottom.set_value(5, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.padding.apply(attr.get_text_box_attr.margins)

    attr1.get_text_box_attr.border.set_colour(:BLACK)
    attr1.get_text_box_attr.border.set_width(1, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.border.set_style(Wx::TEXT_BOX_ATTR_BORDER_SOLID)

    cellAttr = Wx::RichTextAttr.new(attr1)
    cellAttr.get_text_box_attr.width.set_value(200, Wx::TEXT_ATTR_UNITS_PIXELS)
    cellAttr.get_text_box_attr.height.set_value(150, Wx::TEXT_ATTR_UNITS_PIXELS)

    table = r.write_table(6, 4, attr1, cellAttr)

    table.get_row_count.times do |j|
      table.get_column_count.times do |i|
        msg = "This is cell %d, %d" % [(j+1), (i+1)]
        r.set_focus_object(table.cell(j, i))
        r.write_text(msg)
      end
    end

    # Demonstrate colspan and rowspan
    cell = table.cell(1, 0)
    cell.set_col_span(2)
    r.set_focus_object(cell)
    cell.clear
    r.write_text("This cell spans 2 columns")

    cell = table.cell(1, 3)
    cell.set_row_span(2)
    r.set_focus_object(cell)
    cell.clear
    r.write_text("This cell spans 2 rows")

    cell = table.cell(2, 1)
    cell.set_col_span(2)
    cell.set_row_span(3)
    r.set_focus_object(cell)
    cell.clear
    r.write_text("This cell spans 2 columns and 3 rows")

    r.set_focus_object(nil) # Set the focus back to the main buffer
    r.set_insertion_point_end

    r.newline; r.newline

    properties = Wx::RTC::RichTextProperties.new
    r.write_text("This is a rectangle field: ")
    r.write_field("rectangle", properties)
    r.write_text(" and a begin section field: ")
    r.write_field("begin-section", properties)
    r.write_text("This is text between the two tags.")
    r.write_field("end-section", properties)
    r.write_text(" Now a bitmap. ")
    r.write_field("bitmap", properties)
    r.write_text(" Before we go, here's a composite field: ***")
    field = r.write_field("composite", properties)
    field.update_field(r.get_buffer) # Creates the composite value (sort of a text box)
    r.write_text("*** End of composite field.")

    r.newline
    r.end_suppress_undo

    # Add some locked content first - needs Undo to be enabled
    r.begin_lock
    r.write_text("This is a locked object.")
    r.end_lock

    r.write_text(" This is unlocked text. ")

    r.begin_lock
    r.write_text("More locked content.")
    r.end_lock
    r.newline

    # Flush the Undo buffer
    r.command_processor.clear_commands

    r.thaw
  end

end

module RichTextExtSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby extended Wx::RichTextCtrl demo.',
      description: <<~__HEREDOC
        Extended wxRuby sample for Wx::RichTextCtrl
        It includes the following functionality:
        
        * Text entry, paragraph wrapping
        * Scrolling, keyboard navigation
        * Application of character styles:
          bold, italic, underlined, font face, text colour
        * Application of paragraph styles:
          left/right indentation, sub-indentation (first-line indent),
          paragraph spacing (before and after), line spacing,
          left/centre/right alignment, numbered bullets
        * Insertion of images
        * Copy/paste
        * Undo/Redo with optional batching and undo history suppression
        * Named paragraph and character styles management and application
        * File handlers allow addition of file formats
        * Text saving and loading, XML saving and loading, HTML saving (unfinished)
        * etc.
        __HEREDOC
    }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    MyApp.run
  end

end
