#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details

# RichTextCtrl sample by Chauk-Mean Proum
#
# RichTextCtrl is a sophisticated styled text editing component.
# This sample illustrates a basic but functional rich editor featuring :
# - file loading/saving
# - text formatting
# - change undo/redo
# - selection copy/cut and clipboard paste
# - font preferences
# RichTextCtrl supports numerous other text characteristics (colour, super/subscript),
# as well as paragraph alignment and spacing, and bullets.
# It permits named text styles to be created and organised in stylesheets.
# Facilities are also provided for printing.
#
# Icons are taken from the Tango Icon Theme.
# Disabled icons are created at runtime as darkened grayscale versions.

begin
  require 'rubygems'
rescue LoadError
end
require 'wx'

class RichTextFrame < Wx::Frame

  def initialize
    super( nil, :title => "RichTextCtrl Sample", :size => [900, 600] )

    # Initialize the toolbar with standard actions
    initialize_toolbar

    @editor = Wx::RichTextCtrl.new(self, :style => Wx::WANTS_CHARS)

    @editor.begin_text_colour(Wx::RICHTEXT_DEFAULT_FOCUS_RECT_COLOUR)

    # Add extra handlers (plain text is automatically added)
    # @editor.buffer.add_handler(Wx::RichTextXMLHandler.new)
    # @editor.buffer.add_handler(Wx::RichTextHTMLHandler.new)
    Wx::RichTextBuffer.add_handler(Wx::RichTextXMLHandler.new)
    Wx::RichTextBuffer.add_handler(Wx::RichTextHTMLHandler.new)
    file_wildcard = "Text File (*.txt)|*.txt|XML File (*.xml)|*.xml"
    @file_open_wildcard = file_wildcard + "|All Supported File (*.*)|*.*"
    @file_save_wildcard = file_wildcard + "|HTML File (*.html)|*.html"

    @cur_dir = Dir.getwd
    @cur_file = ""
    @cur_filter_index = 1 # XML file

    # Use the system's standard sans-serif font at 18 point
    @editor.font = Wx::Font.new( 18, 
                                 Wx::FONTFAMILY_SWISS,
                                 Wx::FONTSTYLE_NORMAL,
                                 Wx::FONTWEIGHT_NORMAL )

    initialize_text

    # -- For complex event handling, use of a method call --
    evt_tool Wx::ID_OPEN, :open_file
    evt_tool Wx::ID_SAVE, :save_file
    evt_tool Wx::ID_PREFERENCES, :select_font

    # -- For simple event handling, use of a code block --

    # Apply / unapply bold to selection
    evt_tool(Wx::ID_BOLD) do
      @editor.apply_bold_to_selection
    end

    # Keep the pressed / unpressed state of the button in sync with the
    # current selection in the text ctrl
    evt_update_ui(Wx::ID_BOLD) do |evt|
      evt.check(@editor.selection_bold?)
    end

    evt_tool(Wx::ID_ITALIC) do
      @editor.apply_italic_to_selection
    end

    evt_update_ui(Wx::ID_ITALIC) do |evt|
      evt.check(@editor.selection_italics?)
    end

    evt_tool(Wx::ID_UNDERLINE) do
      @editor.apply_underline_to_selection
    end

    evt_update_ui(Wx::ID_UNDERLINE) do |evt|
      evt.check(@editor.selection_underlined?)
    end

    evt_tool(Wx::ID_UNDO) do
      @editor.undo
    end

    evt_update_ui(Wx::ID_UNDO) do |evt|
      evt.enable(@editor.can_undo?)
    end

    evt_tool(Wx::ID_REDO) do
      @editor.redo
    end

    evt_update_ui(Wx::ID_REDO) do |evt|
      evt.enable(@editor.can_redo?)
    end

    evt_tool(Wx::ID_COPY) do
      @editor.copy
    end

    evt_update_ui(Wx::ID_COPY) do |evt|
      evt.enable(@editor.can_copy?)
    end

    evt_tool(Wx::ID_CUT) do
      @editor.cut
    end

    evt_update_ui(Wx::ID_CUT) do |evt|
      evt.enable(@editor.can_cut?)
    end

    evt_tool(Wx::ID_PASTE) do
#      @editor.apply_bold_to_selection if @editor.selection_bold?
#      @editor.apply_italic_to_selection if @editor.selection_italics?
#      @editor.apply_underline_to_selection if @editor.selection_underlined?
      @editor.paste
    end

    evt_update_ui(Wx::ID_PASTE) do |evt|
      evt.enable(@editor.can_paste?)
    end
    # Shortcut keys for the editor
    accel_keys = { "Z" => Wx::ID_UNDO,
                   "Y" => Wx::ID_REDO,
                   "C" => Wx::ID_COPY,
                   "X" => Wx::ID_CUT,
                   "V" => Wx::ID_PASTE }
    accel_table = accel_keys.keys.map do | key | 
      [ Wx::MOD_CMD, key, accel_keys[key] ]
    end

    @editor.accelerator_table = Wx::AcceleratorTable[ *accel_table ]
  end


  # Return bitmaps corresponding to the specified PNG filename :
  # - the first one is the original version (e.g. for an enabled icon)
  # - the second one is a darkened grayscale version (e.g. for a disabled icon)
  def bitmaps_from_png(filename, greyscale = true)
    img_file = File.join( File.dirname(__FILE__), filename)
    normal_bmp = Wx::Bitmap.new(img_file, Wx::BITMAP_TYPE_PNG)
    if greyscale
      greyscale_img = normal_bmp.convert_to_image.convert_to_greyscale(0.2, 0.2, 0.2)
      greyscale_bmp = Wx::Bitmap.from_image(greyscale_img)
      return normal_bmp, greyscale_bmp
    else
      normal_bmp
    end
  end


  # Return a new bitmap corresponding to the specified PNG filename
  def bitmap_from_png(filename)
    bitmaps_from_png(filename, false)
  end


  # Initialize the toolbar
  #
  # As the toolbar contains only standard actions, use of stock/builtin IDs
  # to avoid keeping references to each tool item.
  def initialize_toolbar
    toolbar = create_tool_bar( Wx::TB_HORIZONTAL|Wx::NO_BORDER|
                               Wx::TB_FLAT|Wx::TB_TEXT )
    toolbar.tool_bitmap_size = [ 32, 32 ]

    open_bmp = bitmap_from_png("document-open.png")
    toolbar.add_item(open_bmp, :id => Wx::ID_OPEN,
      :label => "Open", :short_help => "Open file")

    save_bmp = bitmap_from_png("document-save.png")
    toolbar.add_item(save_bmp, :id => Wx::ID_SAVE,
      :label => "Save", :short_help => "Save file")

    font_bmp = bitmap_from_png("preferences-desktop-font.png")
    toolbar.add_item(font_bmp, :id => Wx::ID_PREFERENCES,
      :label => "Font", :short_help => "Select font preferences")

    toolbar.add_separator

    copy_bmp, copy_disabled_bmp = bitmaps_from_png("edit-copy.png")
    toolbar.add_item(copy_bmp, copy_disabled_bmp, :id => Wx::ID_COPY,
      :label => "Copy", :short_help => "Copy selection (CMD+C)")

    cut_bmp, cut_disabled_bmp = bitmaps_from_png("edit-cut.png")
    toolbar.add_item(cut_bmp, cut_disabled_bmp, :id => Wx::ID_CUT,
      :label => "Cut", :short_help => "Cut selection (CMD+X)")

    paste_bmp, paste_disabled_bmp = bitmaps_from_png("edit-paste.png")
    toolbar.add_item(paste_bmp, paste_disabled_bmp, :id => Wx::ID_PASTE,
      :label => "Paste", :short_help => "Paste clipboard (CMD+V)")

    undo_bmp, undo_disabled_bmp = bitmaps_from_png("edit-undo.png")
    toolbar.add_item(undo_bmp, undo_disabled_bmp, :id => Wx::ID_UNDO,
      :label => "Undo", :short_help => "Undo change (CMD+Z)")

    redo_bmp, redo_disabled_bmp = bitmaps_from_png("edit-redo.png")
    toolbar.add_item(redo_bmp, redo_disabled_bmp, :id => Wx::ID_REDO,
      :label => "Redo", :short_help => "Redo change (CMD+Y)")

    toolbar.add_separator

    bold_bmp = bitmap_from_png("format-text-bold.png")
    toolbar.add_item(bold_bmp, :id => Wx::ID_BOLD, :kind => Wx::ITEM_CHECK,
      :label => "Bold", :short_help => "Apply bold")

    italic_bmp = bitmap_from_png("format-text-italic.png")
    toolbar.add_item(italic_bmp, :id => Wx::ID_ITALIC, :kind => Wx::ITEM_CHECK,
      :label => "Italic", :short_help => "Apply italic")

    underline_bmp = bitmap_from_png("format-text-underline.png")
    toolbar.add_item(underline_bmp, :id => Wx::ID_UNDERLINE, :kind => Wx::ITEM_CHECK,
      :label => "Underline", :short_help => "Apply underline")
    
    toolbar.realize
  end

  def initialize_text
    @editor.begin_suppress_undo
    @editor.begin_bold
    @editor.write_text "Simple RichTextCtrl sample"
    @editor.end_bold
    @editor.newline
    @editor.begin_italic
    @editor.write_text "Use the formatting buttons then type some text or "
    @editor.write_text "select some text and use the buttons to apply the formatting.\n"
    @editor.write_text "Save as an XML file in order to keep the text formatting.\n"
    @editor.end_italic
    @editor.newline
    @editor.end_suppress_undo
  end

  def select_font
    data = Wx::FontData.new
    data.initial_font = @editor.font
#    data.enable_effects(false)

    dlg = Wx::FontDialog.new(self, data)
    if dlg.show_modal() == Wx::ID_OK
      data = dlg.font_data
      @editor.font = data.chosen_font
    end
  end

  def open_file
    dlg = Wx::FileDialog.new(self, "Open file", @cur_dir, @cur_file, @file_open_wildcard, Wx::FD_OPEN)
    dlg.filter_index = @cur_filter_index
    if dlg.show_modal() == Wx::ID_OK
      @editor.load_file(dlg.path, Wx::RICHTEXT_TYPE_ANY)
      update_from_file dlg
    end
  end

  def save_file
    dlg = Wx::FileDialog.new(self, "Save file as...", @cur_dir, @cur_file, @file_save_wildcard, Wx::FD_SAVE)
    dlg.filter_index = @cur_filter_index
    if dlg.show_modal() == Wx::ID_OK
      @editor.save_file(dlg.path, Wx::RICHTEXT_TYPE_ANY)
      update_from_file dlg
    end
  end

  # Update current file parameters
  def update_from_file dlg
    @cur_dir = dlg.directory
    @cur_file = dlg.filename
    @cur_filter_index = dlg.filter_index
    self.title = "RichTextCtrl Sample - #{@cur_file}"
  end
end


# The Application
Wx::App.run do 
  self.app_name = 'RichTextCtrl sample'
  frame = RichTextFrame.new
  frame.centre
  frame.show
end
