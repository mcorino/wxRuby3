# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class PropGridTests < WxRuby::Test::GUITests

  def yield_for_a_while(msec)
    timeout = msec / 1000.0 # sec float
    start = ::Time.now
    while (Time.now - start) < timeout
      Wx.get_app.yield
    end
  end

  def populate_with_standard_items(pgman)
    pg = pgman.get_page("Standard Items")

    # Append is ideal way to add items to wxPropertyGrid.
    pg.append(Wx::PG::PropertyCategory.new("Appearance", Wx::PG::PG_LABEL))

    pg.append(Wx::PG::StringProperty.new("Label", Wx::PG::PG_LABEL, 'PropertyGridTest'))
    pg.append(Wx::PG::FontProperty.new("Font", Wx::PG::PG_LABEL))
    pg.set_property_help_string("Font", "Editing this will change font used in the property grid.")

    pg.append(Wx::PG::SystemColourProperty.new("Margin Colour",Wx::PG::PG_LABEL,
                                               Wx::PG::ColourPropertyValue.new(pg.get_grid.get_margin_colour)))

    pg.append(Wx::PG::SystemColourProperty.new("Cell Colour",Wx::PG::PG_LABEL,
                                               pg.grid.get_cell_background_colour))
    pg.append(Wx::PG::SystemColourProperty.new("Cell Text Colour",Wx::PG::PG_LABEL,
                                               pg.grid.get_cell_text_colour))
    pg.append(Wx::PG::SystemColourProperty.new("Line Colour",Wx::PG::PG_LABEL,
                                               pg.grid.get_line_colour))
    combinedFlags = Wx::PG::PGChoices.new
    combinedFlags.add(%w[Wx::ICONIZE, Wx::CAPTION, Wx::MINIMIZE_BOX, Wx::MAXIMIZE_BOX],
                      [Wx::ICONIZE, Wx::CAPTION, Wx::MINIMIZE_BOX, Wx::MAXIMIZE_BOX])
    pg.append(Wx::PG::FlagsProperty.new("Window Styles",Wx::PG::PG_LABEL,
                                        combinedFlags, frame_win.get_window_style))

    pg.append(Wx::PG::CursorProperty.new("Cursor",Wx::PG::PG_LABEL))

    pg.append(Wx::PG::PropertyCategory.new("Position","PositionCategory"))
    pg.set_property_help_string("PositionCategory", "Change in items in this category will cause respective changes in frame.")

    # Let's demonstrate 'Units' attribute here

    # Note that we use many attribute constants instead of strings here
    # (for instance, Wx::PG::PG_ATTR_MIN, instead of "min").
    # Using constant may reduce binary size.

    pg.append(Wx::PG::IntProperty.new("Height",Wx::PG::PG_LABEL,480))
    pg.set_property_attribute("Height", Wx::PG::PG_ATTR_MIN, 10)
    pg.set_property_attribute("Height", Wx::PG::PG_ATTR_MAX, 2048)
    pg.set_property_attribute("Height", Wx::PG::PG_ATTR_UNITS, "Pixels")

    # Set value to unspecified so that Hint attribute will be demonstrated
    pg.set_property_value_unspecified("Height")
    pg.set_property_attribute("Height", Wx::PG::PG_ATTR_HINT,
                              "Enter new height for window")

    # Difference between hint and help string is that the hint is shown in
    # an empty value cell, while help string is shown either in the
    # description text box, as a tool tip, or on the status bar.
    pg.set_property_help_string("Height",
                                "This property uses attributes \"Units\" and \"Hint\".")

    pg.append(Wx::PG::IntProperty.new("Width",Wx::PG::PG_LABEL,640))
    pg.set_property_attribute("Width", Wx::PG::PG_ATTR_MIN, 10)
    pg.set_property_attribute("Width", Wx::PG::PG_ATTR_MAX, 2048)
    pg.set_property_attribute("Width", Wx::PG::PG_ATTR_UNITS, "Pixels")

    pg.set_property_value_unspecified("Width")
    pg.set_property_attribute("Width", Wx::PG::PG_ATTR_HINT,
                              "Enter new width for window")
    pg.set_property_help_string("Width",
                                "This property uses attributes \"Units\" and \"Hint\".")

    pg.append(Wx::PG::IntProperty.new("X",Wx::PG::PG_LABEL,10))
    pg.set_property_attribute("X", Wx::PG::PG_ATTR_UNITS, "Pixels")
    pg.set_property_help_string("X", "This property uses \"Units\" attribute.")

    pg.append Wx::PG::IntProperty.new("Y",Wx::PG::PG_LABEL,10)
    pg.set_property_attribute("Y", Wx::PG::PG_ATTR_UNITS, "Pixels")
    pg.set_property_help_string("Y", "This property uses \"Units\" attribute.")

    disabledHelpString = "This property is simply disabled. In order to have label disabled as well, "+
                         "you need to set Wx::PG::PG_EX_GREY_LABEL_WHEN_DISABLED using SetExtraStyle."

    pg.append(Wx::PG::PropertyCategory.new("Environment",Wx::PG::PG_LABEL))
    pg.append(Wx::PG::StringProperty.new("Operating System",Wx::PG::PG_LABEL, Wx.get_os_description))

    pg.append(Wx::PG::StringProperty.new("User Id",Wx::PG::PG_LABEL, Wx.get_user_id))
    pg.append(Wx::PG::DirProperty.new("User Home",Wx::PG::PG_LABEL, Wx.get_user_home))
    pg.append(Wx::PG::StringProperty.new("User Name",Wx::PG::PG_LABEL, Wx.get_user_name))

    # Disable some of them
    pg.disable_property("Operating System")
    pg.disable_property("User Id")
    pg.disable_property("User Name")

    pg.set_property_help_string("Operating System", disabledHelpString)
    pg.set_property_help_string("User Id", disabledHelpString)
    pg.set_property_help_string("User Name", disabledHelpString)

    pg.append(Wx::PG::PropertyCategory.new("More Examples",Wx::PG::PG_LABEL))

    pg.append(Wx::PG::LongStringProperty.new("Information",Wx::PG::PG_LABEL,
                                             "Editing properties will have immediate effect on this window, "+
                                             "and vice versa (at least in most cases, that is)."))
    pg.set_property_help_string("Information",
                                "This property is read-only.")

    pg.set_property_read_only("Information", true)

    #
    # Set test information for cells in columns 3 and 4
    # (reserve column 2 for displaying units)
    bmp = Wx::ArtProvider.get_bitmap(Wx::ART_FOLDER)

    pg.grid.each_property do |p|
      continue if p.category?

      pg.set_property_cell(p, 3, "Cell 3", bmp)
      pg.set_property_cell(p, 4, "Cell 4", Wx::BitmapBundle.new, Wx::WHITE, Wx::BLACK)
    end
  end

  def populate_with_examples(pgman)
    pg = pgman.get_page("Examples")

    pg.append(Wx::PG::IntProperty.new("IntProperty", Wx::PG::PG_LABEL, 12345678))

    if Wx.has_feature?(:USE_SPINBTN)
      pg.append(Wx::PG::IntProperty.new("SpinCtrl", Wx::PG::PG_LABEL, 0))

      pg.set_property_editor("SpinCtrl", Wx::PG::PG_EDITOR_SPIN_CTRL)
      pg.set_property_attribute("SpinCtrl", Wx::PG::PG_ATTR_MIN, -2)  # Use constants instead of string
      pg.set_property_attribute("SpinCtrl", Wx::PG::PG_ATTR_MAX, 16384)   # for reduced binary size.
      pg.set_property_attribute("SpinCtrl", Wx::PG::PG_ATTR_SPINCTRL_STEP, 2)
      pg.set_property_attribute("SpinCtrl", Wx::PG::PG_ATTR_SPINCTRL_MOTION, true)
      pg.set_property_attribute("SpinCtrl", Wx::PG::PG_ATTR_SPINCTRL_WRAP, true)

      pg.set_property_help_string("SpinCtrl",
                                  "This is regular Wx::PG::IntProperty, which editor has been "+
                                  "changed to Wx::PG::PGEditor_SpinCtrl. Note however that "+
                                  "static wxPropertyGrid::RegisterAdditionalEditors() "+
                                  "needs to be called prior to using it.")
    end

    # Add bool property
    pg.append(Wx::PG::BoolProperty.new("BoolProperty", Wx::PG::PG_LABEL, false))

    # Add bool property with check box
    pg.append(Wx::PG::BoolProperty.new("BoolProperty with CheckBox", Wx::PG::PG_LABEL, false))
    pg.set_property_attribute("BoolProperty with CheckBox",
                              Wx::PG::PG_BOOL_USE_CHECKBOX,
                              true)

    pg.set_property_help_string("BoolProperty with CheckBox",
                                "Property attribute Wx::PG::PG_BOOL_USE_CHECKBOX has been set to true.")

    prop = pg.append(Wx::PG::FloatProperty.new("FloatProperty",
                                               Wx::PG::PG_LABEL,
                                               1234500.23))
    prop.set_attribute(Wx::PG::PG_ATTR_MIN, -100.12)

    # A string property that can be edited in a separate editor dialog.
    pg.append(Wx::PG::LongStringProperty.new("LongStringProperty", "LongStringProp",
                                             "This is much longer string than the first one. Edit it by clicking the button."))

    # A property that edits a wxArrayString.
    example_array = [
      "String 1",
      "String 2",
      "String 3"
    ]
    pg.append(Wx::PG::ArrayStringProperty.new("ArrayStringProperty", Wx::PG::PG_LABEL,
                                              example_array))

    # A file selector property. Note that argument between name
    # and initial value is wildcard (format same as in wxFileDialog).
    prop = Wx::PG::FileProperty.new("FileProperty", "TextFile")
    pg.append(prop)

    prop.set_attribute(Wx::PG::PG_FILE_WILDCARD,"Text Files (*.txt)|*.txt")
    prop.set_attribute(Wx::PG::PG_DIALOG_TITLE,"Custom File Dialog Title")
    prop.set_attribute(Wx::PG::PG_FILE_SHOW_FULL_PATH,false)

    if Wx::PLATFORM == 'WXMSW'
      prop.set_attribute(Wx::PG::PG_FILE_SHOW_RELATIVE_PATH,"C:\\Windows")
      pg.set_property_value(prop,"C:\\Windows\\System32\\msvcrt71.dll")
    end

    if Wx.has_feature? :USE_IMAGE
      # An image file property. Arguments are just like for FileProperty, but
      # wildcard is missing (it is autogenerated from supported image formats).
      # If you really need to override it, create property separately, and call
      # its SetWildcard method.
      pg.append(Wx::PG::ImageFileProperty.new("ImageFile", Wx::PG::PG_LABEL))
    end

    pid = pg.append(Wx::PG::ColourProperty.new("ColourProperty",Wx::PG::PG_LABEL,Wx::RED))
    pg.set_property_editor("ColourProperty", Wx::PG::PG_EDITOR_COMBO_BOX)
    pg.get_property("ColourProperty").set_auto_unspecified(true)
    pg.set_property_help_string("ColourProperty",
                                "wxPropertyGrid::SetPropertyEditor method has been used to change "+
                                "editor of this property to Wx::PG::PGEditor_ComboBox)")

    pid = pg.append(Wx::PG::ColourProperty.new("ColourPropertyWithAlpha",
                                               Wx::PG::PG_LABEL,
                                               Wx::Colour.new(15, 200, 95, 128)))
    pg.set_property_attribute("ColourPropertyWithAlpha", Wx::PG::PG_COLOUR_HAS_ALPHA, true)
    pg.set_property_help_string("ColourPropertyWithAlpha",
                                "Attribute \"HasAlpha\" is set to true for this property.")

    #
    # This demonstrates using alternative editor for colour property
    # to trigger colour dialog directly from button.
    pg.append(Wx::PG::ColourProperty.new("ColourProperty2",Wx::PG::PG_LABEL,Wx::GREEN))

    #
    # Wx::PG::EnumProperty does not store strings or even list of strings
    # (so that's why they are static in function).
    enum_prop_labels = [
      "One Item",
      "Another Item",
      "One More",
      "This Is Last" ]

    # this value array would be optional if values matched string indexes
    enum_prop_values = [ 40, 80, 120, 160 ]

    # note that the initial value (the last argument) is the actual value,
    # not index or anything like that. Thus, our value selects "Another Item".
    pg.append(Wx::PG::EnumProperty.new("EnumProperty",Wx::PG::PG_LABEL,
                                       enum_prop_labels, enum_prop_values, 80))

    soc = Wx::PG::PGChoices.new

    # use basic table from our previous example
    # can also set/add wxArrayStrings and wxArrayInts directly.
    soc.set(enum_prop_labels, enum_prop_values)

    # add extra items
    soc.add("Look, it continues", 200)
    soc.add("Even More", 240)
    soc.add("And More", 280)
    soc.add('', 300)
    soc.add("True End of the List", 320)

    # Test custom colours ([] operator of Wx::PG::PGChoices returns
    # references to Wx::PG::PGChoiceEntry).
    soc[1].set_fg_col(Wx::RED)
    soc[1].set_bg_col(Wx::LIGHT_GREY)
    soc[2].set_fg_col(Wx::GREEN)
    soc[2].set_bg_col(Wx::LIGHT_GREY)
    soc[3].set_fg_col(Wx::BLUE)
    soc[3].set_bg_col(Wx::LIGHT_GREY)
    soc[4].set_bitmap(Wx::ArtProvider.get_bitmap(Wx::ART_FOLDER))

    pg.append(Wx::PG::EnumProperty.new("EnumProperty 2",
                                       Wx::PG::PG_LABEL,
                                       soc,
                                       240))
    pg.get_property("EnumProperty 2").add_choice("Testing Extra", 360)

    # Here we only display the original 'soc' choices
    pg.append(Wx::PG::EnumProperty.new("EnumProperty 3",Wx::PG::PG_LABEL,
                                       soc, 240))

    # Test Hint attribute in EnumProperty
    pg.get_property("EnumProperty 3").set_attribute(Wx::PG::PG_ATTR_HINT, "Dummy Hint")

    pg.set_property_help_string("EnumProperty 3",
                                "This property uses \"Hint\" attribute.")

    # 'soc' plus one exclusive extra choice "4th only"
    pg.append(Wx::PG::EnumProperty.new("EnumProperty 4",Wx::PG::PG_LABEL,
                                       soc, 240))
    pg.get_property("EnumProperty 4").add_choice("4th only", 360)

    pg.set_property_help_string("EnumProperty 4",
                                "Should have one extra item when compared to EnumProperty 3")

    # Plus property value bitmap
    pg.append(Wx::PG::EnumProperty.new("EnumProperty With Bitmap", "EnumProperty 5",
                                       soc, 280))
    pg.set_property_help_string("EnumProperty 5",
                                "Should have bitmap in front of the displayed value")
    bmpVal = Wx::ArtProvider.get_bitmap(Wx::ART_REMOVABLE)
    pg.set_property_image("EnumProperty 5", bmpVal)

    # Password property example.
    pg.append(Wx::PG::StringProperty.new("Password",Wx::PG::PG_LABEL, "password"))
    pg.set_property_attribute("Password", Wx::PG::PG_STRING_PASSWORD, true)
    pg.set_property_help_string("Password",
                                "Has attribute Wx::PG::PG_STRING_PASSWORD set to true")

    # String editor with dir selector button. Uses wxEmptyString as name, which
    # is allowed (naturally, in this case property cannot be accessed by name).
    pg.append(Wx::PG::DirProperty.new("DirProperty", Wx::PG::PG_LABEL, Wx.get_user_home))
    pg.set_property_attribute("DirProperty",
                              Wx::PG::PG_DIALOG_TITLE,
                              "This is a custom dir dialog title")

    # Add string property - first arg is label, second name, and third initial value
    pg.append(Wx::PG::StringProperty.new("StringProperty", Wx::PG::PG_LABEL))
    pg.set_property_max_length("StringProperty", 6)
    pg.set_property_help_string("StringProperty",
                                "Max length of this text has been limited to 6, using wxPropertyGrid::SetPropertyMaxLength.")

    # Set value after limiting so that it will be applied
    pg.set_property_value("StringProperty", "some text")

    #
    # Demonstrate "AutoComplete" attribute
    pg.append(Wx::PG::StringProperty.new("StringProperty AutoComplete",
                                         Wx::PG::PG_LABEL))

    autoCompleteStrings = [
      "One choice",
      "Another choice",
      "Another choice, yeah",
      "Yet another choice",
      "Yet another choice, bear with me"
    ]
    pg.set_property_attribute("StringProperty AutoComplete",
                              Wx::PG::PG_ATTR_AUTOCOMPLETE,
                              autoCompleteStrings)

    pg.set_property_help_string("StringProperty AutoComplete",
                                "AutoComplete attribute has been set for this property "+
                                "(try writing something beginning with 'a', 'o' or 'y').")


    # Add string property with arbitrarily wide bitmap in front of it. We
    # intentionally lower-than-typical row height here so that the ugly
    # scaling code won't be run.
    pg.append(Wx::PG::StringProperty.new("StringPropertyWithBitmap",
                                         Wx::PG::PG_LABEL,
                                         "Test Text"))
    myTestBitmap1x = Wx::Bitmap.new(60, 15, 32)
    Wx::MemoryDC.draw_on(myTestBitmap1x) do |mdc|
      mdc.set_background(Wx::WHITE_BRUSH)
      mdc.clear
      mdc.set_pen(Wx::BLACK_PEN)
      mdc.set_brush(Wx::WHITE_BRUSH)
      mdc.draw_rectangle(0, 0, 60, 15)
      mdc.draw_line(0, 0, 59, 14)
      mdc.set_text_foreground(Wx::BLACK)
      mdc.draw_text("x1", 0, 0)
    end

    myTestBitmap2x = Wx::Bitmap.new(120, 30, 32)
    Wx::MemoryDC.draw_on(myTestBitmap2x) do |mdc|
      mdc.set_background(Wx::WHITE_BRUSH)
      mdc.clear
      mdc.set_pen(Wx::Pen.new(Wx::BLUE, 2))
      mdc.set_brush(Wx::WHITE_BRUSH)
      mdc.draw_rectangle(0, 0, 120, 30)
      mdc.draw_line(0, 0, 119, 31)
      mdc.set_text_foreground(Wx::BLUE)
      f = mdc.font
      f.set_pixel_size(f.get_pixel_size * 2)
      mdc.set_font(f)
      mdc.draw_text("x2", 0, 0)
    end

    myTestBitmap2x.set_scale_factor(2)
    pg.set_property_image("StringPropertyWithBitmap", Wx::BitmapBundle.from_bitmaps(myTestBitmap1x, myTestBitmap2x))

    # Multi choice dialog.
    tchoices = %w[Cabbage Carrot Onion Potato Strawberry]

    tchoicesValues = %w[Carrot Potato]

    pg.append(Wx::PG::EnumProperty.new("EnumProperty X",Wx::PG::PG_LABEL, tchoices))

    pg.append(Wx::PG::MultiChoiceProperty.new("MultiChoiceProperty", Wx::PG::PG_LABEL,
                                              tchoices, tchoicesValues))
    pg.set_property_attribute("MultiChoiceProperty", Wx::PG::PG_ATTR_MULTICHOICE_USERSTRINGMODE, 1)

    # UInt samples
    pg.append(Wx::PG::UIntProperty.new("UIntProperty", Wx::PG::PG_LABEL, 0xFEEEFEEEFEEE))
    pg.set_property_attribute("UIntProperty", Wx::PG::PG_UINT_PREFIX, Wx::PG::PG_PREFIX_NONE)
    pg.set_property_attribute("UIntProperty", Wx::PG::PG_UINT_BASE, Wx::PG::PG_BASE_HEX)
    #pg.set_property_attribute("UIntProperty", Wx::PG::PG_UINT_PREFIX, Wx::PG::PG_PREFIX_NONE)
    #pg.set_property_attribute("UIntProperty", Wx::PG::PG_UINT_BASE, Wx::PG::PG_BASE_OCT)

    #
    # Wx::PG::EditEnumProperty
    eech = Wx::PG::PGChoices.new([
                                   "Choice 1",
                                   "Choice 2",
                                   "Choice 3"
                                 ])
    pg.append(Wx::PG::EditEnumProperty.new("EditEnumProperty",
                                           Wx::PG::PG_LABEL,
                                           eech,
                                           "Choice not in the list"))

    # Test Hint attribute in EditEnumProperty
    pg.get_property("EditEnumProperty").set_attribute(Wx::PG::PG_ATTR_HINT, "Dummy Hint")

    #wxString v_;
    #wxTextValidator validator1(wxFILTER_NUMERIC,&v_)
    #pg.SetPropertyValidator("EditEnumProperty", validator1)

    if Wx.has_feature? :USE_DATETIME
      #
      # Wx::PG::DateTimeProperty
      pg.append(Wx::PG::DateProperty.new("DateProperty", Wx::PG::PG_LABEL, Time.now))

      if Wx.has_feature? :USE_DATEPICKCTRL
        pg.set_property_attribute("DateProperty", Wx::PG::PG_DATE_PICKER_STYLE,
                                  Wx::DP_DROPDOWN|Wx::DP_SHOWCENTURY|Wx::DP_ALLOWNONE)

        pg.set_property_help_string("DateProperty",
                                    "Attribute Wx::PG::PG_DATE_PICKER_STYLE has been set to (long)"+
                                    "(wxDP_DROPDOWN | wxDP_SHOWCENTURY | wxDP_ALLOWNONE).")
      end

    end

    #
    # This snippet is a doc sample test
    #
    carProp = pg.append(Wx::PG::StringProperty.new("Car",
                                                   Wx::PG::PG_LABEL,
                                                   '<composed>'))

    pg.append_in(carProp, Wx::PG::StringProperty.new("Model",
                                                     Wx::PG::PG_LABEL,
                                                     "Lamborghini Diablo SV"))

    pg.append_in(carProp, Wx::PG::IntProperty.new("Engine Size (cc)",
                                                  Wx::PG::PG_LABEL,
                                                  5707))

    speedsProp = pg.append_in(carProp,
                              Wx::PG::StringProperty.new("Speeds",
                                                         Wx::PG::PG_LABEL,
                                                         '<composed>'))

    pg.append_in(speedsProp, Wx::PG::IntProperty.new("Max. Speed (mph)",
                                                     Wx::PG::PG_LABEL,290))
    pg.append_in(speedsProp, Wx::PG::FloatProperty.new("0-100 mph (sec)",
                                                       Wx::PG::PG_LABEL,3.9))
    pg.append_in(speedsProp, Wx::PG::FloatProperty.new("1/4 mile (sec)",
                                                       Wx::PG::PG_LABEL,8.6))

    # This is how child property can be referred to by name
    pg.set_property_value("Car.Speeds.Max. Speed (mph)", 300)

    pg.append_in(carProp, Wx::PG::IntProperty.new("Price ($)",
                                                  Wx::PG::PG_LABEL,
                                                  300000))

    pg.append_in(carProp, Wx::PG::BoolProperty.new("Convertible",
                                                   Wx::PG::PG_LABEL,
                                                   false))

    # Displayed value of "Car" property is now very close to this:
    # "Lamborghini Diablo SV; 5707 [300; 3.9; 8.6] 300000"

    #
    # Test adding variable height bitmaps in Wx::PG::PGChoices
    bc = Wx::PG::PGChoices.new
    bc.add("Wee",
           Wx::ArtProvider.get_bitmap(Wx::ART_CDROM, Wx::ART_OTHER, [16, 16]))
    bc.add("Not so wee",
           Wx::ArtProvider.get_bitmap(Wx::ART_FLOPPY, Wx::ART_OTHER, [32, 32]))
    bc.add("Friggin' huge",
           Wx::ArtProvider.get_bitmap(Wx::ART_HARDDISK, Wx::ART_OTHER, [64, 64]))

    pg.append(Wx::PG::EnumProperty.new("Variable Height Bitmaps",
                                       Wx::PG::PG_LABEL,
                                       bc,
                                       0))

    #
    # Test how non-editable composite strings appear
    pid = Wx::PG::StringProperty.new("wxRuby Traits", Wx::PG::PG_LABEL, "<composed>")
    pg.set_property_read_only(pid)

    #
    # For testing purposes, combine two methods of adding children
    #

    pid.append_child(Wx::PG::StringProperty.new("Latest Release",
                                                Wx::PG::PG_LABEL,
                                                "3.0.0"))
    pid.append_child(Wx::PG::BoolProperty.new("Win API",
                                              Wx::PG::PG_LABEL,
                                              true))

    pg.append(pid)

    pg.append_in(pid, Wx::PG::BoolProperty.new("QT", Wx::PG::PG_LABEL, true))
    pg.append_in(pid, Wx::PG::BoolProperty.new("Cocoa", Wx::PG::PG_LABEL, true))
    pg.append_in(pid, Wx::PG::BoolProperty.new("Haiku", Wx::PG::PG_LABEL, false))
    pg.append_in(pid, Wx::PG::StringProperty.new("Trunk Version", Wx::PG::PG_LABEL, Wx::WXRUBY_VERSION))
    pg.append_in(pid, Wx::PG::BoolProperty.new("GTK+", Wx::PG::PG_LABEL, true))
    pg.append_in(pid, Wx::PG::BoolProperty.new("Android", Wx::PG::PG_LABEL, false))
  end

  def create_grid(style, extraStyle)
    # This function creates the property grid in tests

    style = # default style
      Wx::PG::PG_BOLD_MODIFIED |
      Wx::PG::PG_SPLITTER_AUTO_CENTER |
      Wx::PG::PG_AUTO_SORT |
      Wx::PG::PG_TOOLBAR if style == -1


    # default extra style
    extraStyle = Wx::PG::PG_EX_MODE_BUTTONS |
                 Wx::PG::PG_EX_MULTIPLE_SELECTION if extraStyle == -1

    pg_manager = Wx::PG::PropertyGridManager.new(frame_win, Wx::ID_ANY, style: style)
    pg_manager.set_size(frame_win.get_client_size)
    pg_manager.set_extra_style(extraStyle)

    # This is the default validation failure behaviour
    pg_manager.set_validation_failure_behavior(Wx::PG::PG_VFB_MARK_CELL |
                                              Wx::PG::PG_VFB_SHOW_MESSAGE)

    pg = pg_manager.get_grid
    # Set somewhat different unspecified value appearance
    cell = Wx::PG::PGCell.new
    cell.set_text("Unspecified")
    cell.set_fg_col(Wx::LIGHT_GREY)
    pg.set_unspecified_value_appearance(cell)

    # Populate grid
    pg_manager.add_page("Standard Items")
    populate_with_standard_items(pg_manager)
    pg_manager.add_page("Examples")
    populate_with_examples(pg_manager)

    pg_manager.refresh
    pg_manager.update
    # Wait for update to be done
    yield_for_a_while(200)

    pg_manager
  end
  
  def setup
    super
    frame_win.raise_window
    @pg_manager = create_grid(-1, -1)
  end

  def cleanup
    @pg_manager.destroy
    raise "[#{@pg_manager.ptr_addr}] C++ Object NOT unlinked after destroy" if @pg_manager.ptr_addr != '0x0'
    yield_for_a_while(200)
    super
  end

  def test_iterate
    @pg_manager.each_property(Wx::PG::PG_ITERATE_PROPERTIES) do |prop|
      assert_false(prop.is_category, "'#{prop.get_label}' is a category (non-private child property expected)")
      assert_false(prop.get_parent.has_flag(Wx::PG::PG_PROP_AGGREGATE), "'#{prop.get_label}' is a private child (non-private child property expected)")
    end
    @pg_manager.each_property(Wx::PG::PG_ITERATE_CATEGORIES) do |prop|
      assert_true(prop.is_category, "'#{prop.get_label}' is not a category (only categories expected)")
    end
    @pg_manager.each_property(Wx::PG::PG_ITERATE_PROPERTIES|Wx::PG::PG_ITERATE_CATEGORIES) do |prop|
      assert_false(prop.get_parent.has_flag(Wx::PG::PG_PROP_AGGREGATE), "'#{prop.get_label}' is a private child (non-private child property or category expected)")
    end
    @pg_manager.each_property(Wx::PG::PG_ITERATE_VISIBLE) do |prop|
      assert_true(prop.parent == @pg_manager.grid.root || prop.parent.expanded?, "'#{prop.get_label}' had collapsed parent (only visible properties expected)")
      assert_false(prop.has_flag(Wx::PG::PG_PROP_HIDDEN), "'#{prop.get_label}' was hidden (only visible properties expected)")
    end
  end

  unless is_ci_build?

    def test_iterate_delete_first_page_then_last
      # Get all properties from first page
      pageFirst = @pg_manager.get_page(0)
      properties_page_first_init = pageFirst.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).collect { |prop| prop.get_name }
      # Get all properties from last page
      pageLast = @pg_manager.get_page(@pg_manager.get_page_count - 1)
      properties_page_last_init = pageLast.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).collect { |prop| prop.get_name }

      countAllPropertiesInit = @pg_manager.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count

      # Delete all properties from first page
      pageFirst.clear

      assert_true(pageFirst.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count == 0)

      properties_page_last = pageLast.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).collect { |prop| prop.get_name }
      assert_equal(properties_page_last_init, properties_page_last)

      countAllProperties = @pg_manager.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count
      assert_equal(countAllPropertiesInit-properties_page_first_init.size, countAllProperties)

      # Delete all properties from last page
      pageLast.clear

      assert_true(pageFirst.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count == 0)

      assert_true(pageLast.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count == 0)

      countAllProperties = @pg_manager.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count
      assert_equal(countAllPropertiesInit-properties_page_first_init.size-properties_page_last_init.size, countAllProperties)
    end

    def test_iterate_delete_last_page_then_first
      # Get all properties from first page
      pageFirst = @pg_manager.get_page(0)
      properties_page_first_init = pageFirst.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).collect { |prop| prop.get_name }
      # Get all properties from last page
      pageLast = @pg_manager.get_page(@pg_manager.get_page_count - 1)
      properties_page_last_init = pageLast.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).collect { |prop| prop.get_name }

      countAllPropertiesInit = @pg_manager.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count

      # Delete all properties from last page
      pageLast.clear

      assert_true(pageLast.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count == 0)

      properties_page_first = pageFirst.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).collect { |prop| prop.get_name }
      assert_equal(properties_page_first_init, properties_page_first)

      countAllProperties = @pg_manager.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count
      assert_equal(countAllPropertiesInit-properties_page_last_init.size, countAllProperties)

      # Delete all properties from first page
      pageFirst.clear

      assert_true(pageLast.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count == 0)

      assert_true(pageFirst.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count == 0)

      countAllProperties = @pg_manager.each_property(Wx::PG::PG_ITERATOR_FLAGS_ALL | Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_ITERATOR_FLAGS_ALL)).count
      assert_equal(countAllPropertiesInit-properties_page_first_init.size-properties_page_last_init.size, countAllProperties)
    end

    def test_select_property
      # Test that setting focus to properties does not crash things
      @pg_manager.page_count.times do |pc|
        page = @pg_manager.page(pc)
        @pg_manager.select_page(page)

        page.each_property(Wx::PG::PG_ITERATE_VISIBLE) do |prop|
          @pg_manager.grid.select_property(prop, true)
          sleep(0.150)
          frame_win.update
        end
      end
    end

  end

  def test_delete_property
    # delete everything in reverse order

    array = @pg_manager.each_property(Wx::PG::PG_ITERATE_ALL & ~(Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_PROP_AGGREGATE))).to_a
    array.reverse_each { |prop| @pg_manager.delete_property(prop) }

    assert_true(@pg_manager.each_property(Wx::PG::PG_ITERATE_ALL & ~(Wx::PG.PG_IT_CHILDREN(Wx::PG::PG_PROP_AGGREGATE))).count == 0, "Not all properties are deleted")

    @pg_manager.refresh
    @pg_manager.update
    # Wait for update to be done
    yield_for_a_while(100)
  end

  def test_default_values
    @pg_manager.each_property(Wx::PG::PG_ITERATE_PROPERTIES) do |prop|
      @pg_manager.set_property_value(prop, prop.default_value)
    end
  end

  def test_set_get_property_values
    test_arrstr_1 = %w[Apple Orange Lemon]

    test_arrstr_2 = %w[Potato Cabbage Cucumber]

    test_arrint_1 = [1,2,3]

    test_arrint_2 = [0,1,4]

    if Wx.has_feature? :USE_DATETIME
      dt1 = Time.now
      dt1 = Time.new(dt1.year, dt1.month, 28) if dt1.month == 2 && dt1.day == 29

      dt2 = Time.new(dt1.year-10, dt1.month, dt1.day)
      dt1 = Time.new(dt1.year-1, dt1.month, dt1.day)
    end

    @pg_manager.set_property_value("StringProperty", "Text1")
    @pg_manager.set_property_value("IntProperty", 1024)
    @pg_manager.set_property_value("FloatProperty", 1024.0000000001)
    @pg_manager.set_property_value("BoolProperty", false)
    @pg_manager.set_property_value("EnumProperty", 120)
    @pg_manager.set_property_value("ArrayStringProperty", test_arrstr_1)
    @pg_manager.set_property_value("ColourProperty", Wx::Colour.new)
    @pg_manager.set_property_value("ColourProperty", Wx::BLACK)
    @pg_manager.set_property_value("MultiChoiceProperty", test_arrint_1)
    if Wx.has_feature? :USE_DATETIME
      @pg_manager.set_property_value("DateProperty", dt1)
    end

    @pg_manager.select_page(1)
    pg = @pg_manager.grid

    assert_equal("Text1", pg.get_property_value_as_string("StringProperty"))
    assert_equal(1024, pg.get_property_value_as_int("IntProperty"))
    assert_equal(1024.0000000001, pg.get_property_value_as_double("FloatProperty"))
    assert_false(pg.get_property_value_as_bool("BoolProperty"))
    assert_equal(120, pg.get_property_value_as_long("EnumProperty"))
    assert_equal(test_arrstr_1, pg.get_property_value_as_array_string("ArrayStringProperty"))
    col = @pg_manager.get_property_value("ColourProperty").get_colour
    assert_equal(Wx::BLACK, col)
    assert_equal(test_arrint_1, pg.get_property_value_as_array_int("MultiChoiceProperty"))
    if Wx.has_feature? :USE_DATETIME
      assert_equal(dt1, pg.get_property_value_as_date_time("DateProperty"))
    end

    @pg_manager.set_property_value("IntProperty", 10000000000)
    assert_equal(10000000000, pg.get_property_value_as_long_long("IntProperty"))

    pg.set_property_value("StringProperty", "Text2")
    pg.set_property_value("IntProperty", 512)
    pg.set_property_value("FloatProperty", 512.0)
    pg.set_property_value("BoolProperty", true)
    pg.set_property_value("EnumProperty", 80)
    pg.set_property_value("ArrayStringProperty", test_arrstr_2)
    pg.set_property_value("ColourProperty", Wx::WHITE)
    pg.set_property_value("MultiChoiceProperty", test_arrint_2)
    if Wx.has_feature? :USE_DATETIME
      pg.set_property_value("DateProperty", dt2)
    end

    @pg_manager.select_page(0)

    assert_equal("Text2", @pg_manager.get_property_value_as_string("StringProperty"))
    assert_equal(512, @pg_manager.get_property_value_as_int("IntProperty"))
    assert_equal(512.0, @pg_manager.get_property_value_as_double("FloatProperty"))
    assert_true(@pg_manager.get_property_value_as_bool("BoolProperty"))
    assert_equal(80, @pg_manager.get_property_value_as_long("EnumProperty"))
    assert_equal(test_arrstr_2, @pg_manager.get_property_value_as_array_string("ArrayStringProperty"))
    col = @pg_manager.get_property_value("ColourProperty").colour
    assert_equal(Wx::WHITE, col)
    assert_equal(test_arrint_2, @pg_manager.get_property_value_as_array_int("MultiChoiceProperty"))
    if Wx.has_feature? :USE_DATETIME
      assert_equal(dt2, @pg_manager.get_property_value_as_date_time("DateProperty"))
    end

    @pg_manager.set_property_value("IntProperty", -80000000000)
    assert_equal(-80000000000, @pg_manager.get_property_value_as_long_long("IntProperty"))

    nvs = 'Lamborghini Diablo XYZ; 5707; [100; 3.9; 8.6] 3000002; Convertible'
    @pg_manager.set_property_value("Car", nvs)
    assert_equal("Lamborghini Diablo XYZ", @pg_manager.get_property_value_as_string("Car.Model"))
    assert_equal(100, @pg_manager.get_property_value_as_int("Car.Speeds.Max. Speed (mph)"))
    assert_equal(3000002, @pg_manager.get_property_value_as_int("Car.Price ($)"))
    assert_true(@pg_manager.get_property_value_as_bool("Car.Convertible"))

    # SetPropertyValueString for special cases such as wxColour
    @pg_manager.set_property_value_string("ColourProperty", "(123,4,255)")
    col = @pg_manager.get_property_value("ColourProperty").colour
    assert_equal(Wx::Colour.new(123, 4, 255), col)
    @pg_manager.set_property_value_string("ColourProperty", "#FE860B")
    col = @pg_manager.get_property_value("ColourProperty").colour
    assert_equal(Wx::Colour.new("#FE860B"), col)

    @pg_manager.set_property_value_string("ColourPropertyWithAlpha", "(10, 20, 30, 128)")
    col = @pg_manager.get_property_value("ColourPropertyWithAlpha").colour
    assert_equal(Wx::Colour.new(10, 20, 30, 128), col)
    assert_equal("(10,20,30,128)", @pg_manager.get_property_value_as_string("ColourPropertyWithAlpha"))
  end

  def test_set_property_value_unspecified
    # Null variant setter tests
    @pg_manager.set_property_value_unspecified("StringProperty")
    @pg_manager.set_property_value_unspecified("IntProperty")
    @pg_manager.set_property_value_unspecified("FloatProperty")
    @pg_manager.set_property_value_unspecified("BoolProperty")
    @pg_manager.set_property_value_unspecified("EnumProperty")
    @pg_manager.set_property_value_unspecified("ArrayStringProperty")
    @pg_manager.set_property_value_unspecified("ColourProperty")
    @pg_manager.set_property_value_unspecified("MultiChoiceProperty")
    if Wx.has_feature? :USE_DATETIME
      @pg_manager.set_property_value_unspecified("DateProperty")
    end
  end

  def replace_grid(style, extraStyle)
    @pg_manager.destroy # First destroy previous instance
    @pg_manager = create_grid(style, extraStyle)
    @pg_manager.set_focus
  end

  def test_multiple_selection
    replace_grid(-1, Wx::PG::PG_EX_MULTIPLE_SELECTION) unless @pg_manager.get_extra_style & Wx::PG::PG_EX_MULTIPLE_SELECTION

    pg = @pg_manager.grid

    prop1 = pg.get_property("Label")
    prop2 = pg.get_property("Cell Text Colour")
    prop3 = pg.get_property("Height")
    catProp = pg.get_property("Appearance")

    assert_not_nil(prop1)
    assert_not_nil(prop2)
    assert_not_nil(prop3)

    pg.clear_selection
    pg.add_to_selection(prop1)
    pg.add_to_selection(prop2)
    pg.add_to_selection(prop3)

    # Adding category to selection should fail silently
    pg.add_to_selection(catProp)

    selectedProperties = pg.get_selected_properties

    assert_equal(3, selectedProperties.size)
    assert_true(pg.is_property_selected(prop1))
    assert_true(pg.is_property_selected(prop2))
    assert_true(pg.is_property_selected(prop3))
    assert_false(pg.is_property_selected(catProp))

    pg.remove_from_selection(prop1)
    selectedProperties2 = pg.get_selected_properties

    assert_equal(2, selectedProperties2.size)
    assert_false(pg.is_property_selected(prop1))
    assert_true(pg.is_property_selected(prop2))
    assert_true(pg.is_property_selected(prop3))

    pg.clear_selection

    selectedProperties3 = pg.get_selected_properties

    assert_equal(0, selectedProperties3.size)
    assert_false(pg.is_property_selected(prop1))
    assert_false(pg.is_property_selected(prop2))
    assert_false(pg.is_property_selected(prop3))

    pg.select_property(prop2)

    assert_false(pg.is_property_selected(prop1))
    assert_true(pg.is_property_selected(prop2))
    assert_false(pg.is_property_selected(prop3))
  end

end
