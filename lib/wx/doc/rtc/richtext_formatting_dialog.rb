# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx::RTC

  RICHTEXT_FORMAT_MARGINS = 0x0040
  RICHTEXT_FORMAT_SIZE = 0x0080
  RICHTEXT_FORMAT_BORDERS = 0x0100
  RICHTEXT_FORMAT_BACKGROUND = 0x0200

  class RichTextFormattingDialog

    # Returns associated richtext object
    # @return [Wx::RTC::RichTextObject]
    def get_object; end
    alias :object :get_object

    # Sets associated richtext object
    # @param [Wx::RTC::Object] obj
    # @return [void]
    def set_object(obj) end
    alias :object= :set_object

    # Apply attributes to the object being edited, only changing attributes that need to be changed.
    # @param ctrl [Wx::RTC::RichTextCtrl]
    # @param flags [Integer]
    # @return [true,false]
    def apply_style(ctrl, flags=Wx::RTC::RICHTEXT_SETSTYLE_WITH_UNDO) end

  end

  class RichTextObjectPropertiesDialog < RichTextFormattingDialog

    ID_RICHTEXTOBJECTPROPERTIESDIALOG = 10650

    # @overload initialize()
    #   Default ctor.
    #   @return [Wx::RTC::RichTextObjectPropertiesDialog]
    # @overload initialize(obj, parent, caption=("Object Properties"), id=ID_RICHTEXTOBJECTPROPERTIESDIALOG, pos=Wx::DEFAULT_POSITION, sz=[400,300], style=Wx::DEFAULT_DIALOG_STYLE|Wx::TAB_TRAVERSAL)
    #   Constructors.
    #   @param obj [Wx::RTC::RichTextObject]  The richtext object to edit properties of.
    #   @param parent [Wx::Window]  The dialog's parent.
    #   @param caption [String]  The dialog's title.
    #   @param id [Integer]  The dialog's ID.
    #   @param pos [Array(Integer, Integer), Wx::Point]  The dialog's position.
    #   @param sz [Array(Integer, Integer), Wx::Size]  The dialog's size.
    #   @param style [Integer]  The dialog's window style.
    #   @return [Wx::RTC::RichTextObjectPropertiesDialog]
    def initialize(*args) end

    # Creation: see {Wx::RTC::RichTextObjectPropertiesDialog#initialize} "the constructor" for details about the parameters.
    # @param obj [Wx::RTC::RichTextObject]
    # @param parent [Wx::Window]
    # @param caption [String]
    # @param id [Integer]
    # @param pos [Array(Integer, Integer), Wx::Point]
    # @param size [Array(Integer, Integer), Wx::Size]
    # @param style [Integer]
    # @return [true,false]
    def create(obj, parent, id = ID_RICHTEXTOBJECTPROPERTIESDIALOG, caption = 'Object Properties', pos = Wx::DEFAULT_POSITION, size = [400,300], style = Wx::DEFAULT_DIALOG_STYLE|Wx::TAB_TRAVERSAL) end

  end

end
